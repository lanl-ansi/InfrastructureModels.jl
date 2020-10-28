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

    cit::Symbol
    cnw::Int

    # Extension dictionary
    # Extensions should define a type to hold information particular to
    # their functionality, and store an instance of the type in this
    # dictionary keyed on an extension-specific symbol
    ext::Dict{Symbol,<:Any}
end

infrastructure_type(InfrastructureModel::Type) = :none


# default generic constructor
function InitializeInfrastructureModel(InfrastructureModel::Type, data::Dict{String,<:Any}, global_keys::Set{String}; ext = Dict{Symbol,Any}(), setting = Dict{String,Any}(), jump_model::JuMP.AbstractModel=JuMP.Model())
    @assert InfrastructureModel <: AbstractInfrastructureModel

    it_default = infrastructure_type(InfrastructureModel)
    ref = ref_initialize(data, it_default, global_keys) # reference data

    var = Dict{Symbol,Any}(:it => Dict(it_default => Dict(:nw => Dict{Int,Any}())))
    con = Dict{Symbol,Any}(:it => Dict(it_default => Dict(:nw => Dict{Int,Any}())))
    sol = Dict{Symbol,Any}(:it => Dict(it_default => Dict(:nw => Dict{Int,Any}())))
    sol_proc = Dict{Symbol,Any}(:it => Dict(it_default => Dict(:nw => Dict{Int,Any}())))

    for (nw_id, nw) in ref[:it][it_default][:nw]
        nw_var = var[:it][it_default][:nw][nw_id] = Dict{Symbol,Any}()
        nw_con = con[:it][it_default][:nw][nw_id] = Dict{Symbol,Any}()
        nw_sol = sol[:it][it_default][:nw][nw_id] = Dict{Symbol,Any}()
        nw_sol_proc = sol_proc[:it][it_default][:nw][nw_id] = Dict{Symbol,Any}()
    end

    cnw = minimum([k for k in keys(ref[:it][it_default][:nw])])

    imo = InfrastructureModel(
        jump_model,
        data,
        setting,
        Dict{String,Any}(), # empty solution data
        ref,
        var,
        con,
        sol,
        sol_proc,
        it_default,
        cnw,
        ext
    )

    return imo
end


"""
Given a data dictionary following the Infrastructure Models conventions, builds
an initial "ref" dictionary converting strings to symbols and component
keys to integers.  The global keys argument specifies which keys should remain
in the root of dictionary when building a multi-network
"""
function ref_initialize(data::Dict{String,<:Any}, it_default::Symbol, global_keys::Set{String}=Set{String}())
    refs = Dict{Symbol,Any}()

    if ismultinetwork(data)
        nws_data = inf_data["nw"]
        for (key, item) in inf_data
            if key != "nw"
                refs[Symbol(iid)][Symbol(key)] = item
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

    nws = Dict{Int,Any}()

    for (n, nw_data) in nws_data
        nw_id = parse(Int, n)
        nw = nws[nw_id] = Dict{Symbol,Any}()

        for (key, item) in nw_data
            if !(key in global_keys)
                if isa(item, Dict{String,Any}) && _iscomponentdict(item)
                    item_lookup = Dict{Int,Any}([(parse(Int, k), v) for (k,v) in item])
                    nw[Symbol(key)] = item_lookup
                else
                    nw[Symbol(key)] = item
                end
            end
        end
    end

    refs[:it] = Dict(it_default => Dict(:nw => nws))

    return refs
end

"used for building ref without the need to initialize an AbstractInfrastructureModel"
function build_ref(data::Dict{String,<:Any}, ref_add_core!, global_keys::Set{String}; ref_extensions=[])
    ref = ref_initialize(data, global_keys)
    ref_add_core!(ref)
    for ref_ext in ref_extensions
        ref_ext(ref, data)
    end
    return ref
end


report_duals(aim::AbstractInfrastructureModel) = haskey(aim.setting, "output") && haskey(aim.setting["output"], "duals") && aim.setting["output"]["duals"] == true

### Helper functions for working with AbstractInfrastructureModels
ismultinetwork(aim::AbstractInfrastructureModel) = ismultinetwork(aim.data)
nw_ids(aim::AbstractInfrastructureModel; it::Symbol=aim.cit) = keys(aim.ref[:it][it][:nw])
nws(aim::AbstractInfrastructureModel; it::Symbol=aim.cit) = aim.ref[:it][it][:nw]


ids(aim::AbstractInfrastructureModel, nw::Int, key::Symbol; it::Symbol=aim.cit) = keys(aim.ref[:it][it][:nw][nw][key])
ids(aim::AbstractInfrastructureModel, key::Symbol; it::Symbol=aim.cit, nw::Int=aim.cnw) = keys(aim.ref[:it][it][:nw][nw][key])


ref(aim::AbstractInfrastructureModel, nw::Int; it::Symbol=aim.cit) = aim.ref[:it][it][:nw][nw]
ref(aim::AbstractInfrastructureModel, nw::Int, key::Symbol; it::Symbol=aim.cit) = aim.ref[:it][it][:nw][nw][key]
ref(aim::AbstractInfrastructureModel, nw::Int, key::Symbol, idx; it::Symbol=aim.cit) = aim.ref[:it][it][:nw][nw][key][idx]
ref(aim::AbstractInfrastructureModel, nw::Int, key::Symbol, idx, param::String; it::Symbol=aim.cit) = aim.ref[:it][it][:nw][nw][key][idx][param]

ref(aim::AbstractInfrastructureModel; it::Symbol=aim.cit, nw::Int=aim.cnw) = aim.ref[:it][it][:nw][nw]
ref(aim::AbstractInfrastructureModel, key::Symbol; it::Symbol=aim.cit, nw::Int=aim.cnw) = aim.ref[:it][it][:nw][nw][key]
ref(aim::AbstractInfrastructureModel, key::Symbol, idx; it::Symbol=aim.cit, nw::Int=aim.cnw) = aim.ref[:it][it][:nw][nw][key][idx]
ref(aim::AbstractInfrastructureModel, key::Symbol, idx, param::String; it::Symbol=aim.cit, nw::Int=aim.cnw) = aim.ref[:it][it][:nw][nw][key][idx][param]


var(aim::AbstractInfrastructureModel, nw::Int; it::Symbol=aim.cit) = aim.var[:it][it][:nw][nw]
var(aim::AbstractInfrastructureModel, nw::Int, key::Symbol; it::Symbol=aim.cit) = aim.var[:it][it][:nw][nw][key]
var(aim::AbstractInfrastructureModel, nw::Int, key::Symbol, idx; it::Symbol=aim.cit) = aim.var[:it][it][:nw][nw][key][idx]

var(aim::AbstractInfrastructureModel; it::Symbol=aim.cit, nw::Int=aim.cnw) = aim.var[:it][it][:nw][nw]
var(aim::AbstractInfrastructureModel, key::Symbol; it::Symbol=aim.cit, nw::Int=aim.cnw) = aim.var[:it][it][:nw][nw][key]
var(aim::AbstractInfrastructureModel, key::Symbol, idx; it::Symbol=aim.cit, nw::Int=aim.cnw) = aim.var[:it][it][:nw][nw][key][idx]


con(aim::AbstractInfrastructureModel, nw::Int) = aim.con[:nw][nw]
con(aim::AbstractInfrastructureModel, nw::Int, key::Symbol) = aim.con[:nw][nw][key]
con(aim::AbstractInfrastructureModel, nw::Int, key::Symbol, idx) = aim.con[:nw][nw][key][idx]

con(aim::AbstractInfrastructureModel; nw::Int=aim.cnw) = aim.con[:nw][nw]
con(aim::AbstractInfrastructureModel, key::Symbol; nw::Int=aim.cnw) = aim.con[:nw][nw][key]
con(aim::AbstractInfrastructureModel, key::Symbol, idx; nw::Int=aim.cnw) = aim.con[:nw][nw][key][idx]


sol(aim::AbstractInfrastructureModel, nw::Int, args...; it::Symbol=aim.cit) = _sol(aim.sol[:it][it][:nw][nw], args...)
sol(aim::AbstractInfrastructureModel, args...; it::Symbol=aim.cit, nw::Int=aim.cnw) = _sol(aim.sol[:it][it][:nw][nw], args...)

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
function instantiate_model(data::Dict{String,<:Any}, model_type::Type, build_method, ref_add_core!, global_keys::Set{String}; ref_extensions=[], kwargs...)
    # NOTE, this model constructor will build the ref dict using the latest info from the data

    start_time = time()
    imo = InitializeInfrastructureModel(model_type, data, global_keys; kwargs...)
    Memento.debug(_LOGGER, "initialize model time: $(time() - start_time)")

    start_time = time()
    ref_add_core!(imo.ref)
    for ref_ext! in ref_extensions
        ref_ext!(imo.ref, imo.data)
    end
    Memento.debug(_LOGGER, "build ref time: $(time() - start_time)")

    start_time = time()
    build_method(imo)
    Memento.debug(_LOGGER, "build method time: $(time() - start_time)")

    return imo
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
