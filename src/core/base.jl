"""
The `def` macro is used to build other macros that can insert the same block of
julia code into different parts of a program.  In InfrastructureModels packages
this is macro is used to generate a standard set of fields inside a model type
hierarchy.
"""
macro def(name, definition)
    return quote
        macro $(esc(name))()
            esc($(Expr(:quote, definition)))
        end
    end
end

"root of the infrastructure model formulation type hierarchy"
abstract type AbstractInfrastructureModel end

"a macro for adding the standard InfrastructureModels fields to a type definition"
InfrastructureModels.@def im_fields begin
    model::JuMP.AbstractModel

    data::Dict{String,<:Any}
    setting::Dict{String,<:Any}
    solution::Dict{String,<:Any}

    ref::Dict{Symbol,<:Any}
    var::Dict{Symbol,<:Any}
    con::Dict{Symbol,<:Any}

    sol::Dict{Symbol,<:Any}
    sol_proc::Dict{Symbol,<:Any}

    cnw::Int

    # Extension dictionary
    # Extensions should define a type to hold information particular to
    # their functionality, and store an instance of the type in this
    # dictionary keyed on an extension-specific symbol
    ext::Dict{Symbol,<:Any}
end


"""
Given a data dictionary following the Infrastructure Models conventions, builds
an initial "ref" dictionary converting strings to symbols and component
keys to integers.  The global keys argument specifies which keys should remain
in the root of dictionary when building a multi-network
"""
function ref_initialize(data::Dict{String,<:Any}, global_keys::Set{String}=Set{String}())
    refs = Dict{Symbol,Any}()

    if ismultinetwork(data)
        nws_data = data["nw"]
        for (key, item) in data
            if key != "nw"
                refs[Symbol(key)] = item
            end
        end
    else
        nws_data = Dict("0" => data)
        for global_key in global_keys
            if haskey(data, global_key)
                refs[Symbol(global_key)] = data[global_key]
            end
        end
    end

    nws = refs[:nw] = Dict{Int,Any}()

    for (n, nw_data) in nws_data
        nw_id = parse(Int, n)
        ref = nws[nw_id] = Dict{Symbol,Any}()

        for (key, item) in nw_data
            if !(key in global_keys)
                if isa(item, Dict{String,Any}) && _iscomponentdict(item)
                    item_lookup = Dict{Int,Any}([(parse(Int, k), v) for (k,v) in item])
                    ref[Symbol(key)] = item_lookup
                else
                    ref[Symbol(key)] = item
                end
            end
        end
    end

    return refs
end


report_duals(aim::AbstractInfrastructureModel) = haskey(aim.setting, "output") && haskey(aim.setting["output"], "duals") && aim.setting["output"]["duals"] == true

### Helper functions for working with multinetworks

ismultinetwork(aim::AbstractInfrastructureModel) = (length(aim.ref[:nw]) > 1)


nw_ids(aim::AbstractInfrastructureModel) = keys(aim.ref[:nw])


nws(aim::AbstractInfrastructureModel) = aim.ref[:nw]


ids(aim::AbstractInfrastructureModel, nw::Int, key::Symbol) = keys(aim.ref[:nw][nw][key])
ids(aim::AbstractInfrastructureModel, key::Symbol; nw::Int=aim.cnw) = keys(aim.ref[:nw][nw][key])


ref(aim::AbstractInfrastructureModel, nw::Int) = aim.ref[:nw][nw]
ref(aim::AbstractInfrastructureModel, nw::Int, key::Symbol) = aim.ref[:nw][nw][key]
ref(aim::AbstractInfrastructureModel, nw::Int, key::Symbol, idx) = aim.ref[:nw][nw][key][idx]
ref(aim::AbstractInfrastructureModel, nw::Int, key::Symbol, idx, param::String) = aim.ref[:nw][nw][key][idx][param]

ref(aim::AbstractInfrastructureModel; nw::Int=aim.cnw) = aim.ref[:nw][nw]
ref(aim::AbstractInfrastructureModel, key::Symbol; nw::Int=aim.cnw) = aim.ref[:nw][nw][key]
ref(aim::AbstractInfrastructureModel, key::Symbol, idx; nw::Int=aim.cnw) = aim.ref[:nw][nw][key][idx]
ref(aim::AbstractInfrastructureModel, key::Symbol, idx, param::String; nw::Int=aim.cnw) = aim.ref[:nw][nw][key][idx][param]


var(aim::AbstractInfrastructureModel, nw::Int) = aim.var[:nw][nw]
var(aim::AbstractInfrastructureModel, nw::Int, key::Symbol) = aim.var[:nw][nw][key]
var(aim::AbstractInfrastructureModel, nw::Int, key::Symbol, idx) = aim.var[:nw][nw][key][idx]

var(aim::AbstractInfrastructureModel; nw::Int=aim.cnw) = aim.var[:nw][nw]
var(aim::AbstractInfrastructureModel, key::Symbol; nw::Int=aim.cnw) = aim.var[:nw][nw][key]
var(aim::AbstractInfrastructureModel, key::Symbol, idx; nw::Int=aim.cnw) = aim.var[:nw][nw][key][idx]


con(aim::AbstractInfrastructureModel, nw::Int) = aim.con[:nw][nw]
con(aim::AbstractInfrastructureModel, nw::Int, key::Symbol) = aim.con[:nw][nw][key]
con(aim::AbstractInfrastructureModel, nw::Int, key::Symbol, idx) = aim.con[:nw][nw][key][idx]

con(aim::AbstractInfrastructureModel; nw::Int=aim.cnw) = aim.con[:nw][nw]
con(aim::AbstractInfrastructureModel, key::Symbol; nw::Int=aim.cnw) = aim.con[:nw][nw][key]
con(aim::AbstractInfrastructureModel, key::Symbol, idx; nw::Int=aim.cnw) = aim.con[:nw][nw][key][idx]


sol(aim::AbstractInfrastructureModel, nw::Int, args...) = _sol(aim.sol[:nw][nw], args...)
sol(aim::AbstractInfrastructureModel, args...; nw::Int=aim.cnw) = _sol(aim.sol[:nw][nw], args...)

function _sol(sol::Dict, args...)
    for arg in args
        if haskey(sol, arg)
            sol = sol[arg]
        else
            sol = sol[arg] = Dict()
        end
    end
    return sol
end


""
function optimize_model!(aim::AbstractInfrastructureModel; optimizer=nothing, solution_processors=[])
    start_time = time()

    if optimizer != nothing
        if aim.model.moi_backend.state == _MOI.Utilities.NO_OPTIMIZER
            JuMP.set_optimizer(aim.model, optimizer)
        else
            Memento.warn(_LOGGER, "Model already contains optimizer, cannot use optimizer specified in `optimize_model!`")
        end
    end

    if aim.model.moi_backend.state == _MOI.Utilities.NO_OPTIMIZER
        Memento.error(_LOGGER, "no optimizer specified in `optimize_model!` or the given JuMP model.")
    end

    _, solve_time, solve_bytes_alloc, sec_in_gc = @timed JuMP.optimize!(aim.model)

    try
        solve_time = _MOI.get(aim.model, _MOI.SolveTime())
    catch
        Memento.warn(_LOGGER, "the given optimizer does not provide the SolveTime() attribute, falling back on @timed.  This is not a rigorous timing value.");
    end
    Memento.debug(_LOGGER, "JuMP model optimize time: $(time() - start_time)")

    start_time = time()
    result = build_result(aim, solve_time; solution_processors=solution_processors)
    Memento.debug(_LOGGER, "solution build time: $(time() - start_time)")

    aim.solution = result["solution"]

    return result
end
