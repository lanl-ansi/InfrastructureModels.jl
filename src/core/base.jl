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

    # Extension dictionary
    # Extensions should define a type to hold information particular to
    # their functionality, and store an instance of the type in this
    # dictionary keyed on an extension-specific symbol
    ext::Dict{Symbol,<:Any}
end


"Constructor for an InfrastructureModels modeling object, where `data` is
assumed to in a multi-infrastructure network data format."
function InitializeInfrastructureModel(
    InfrastructureModel::Type, data::Dict{String, <:Any}, global_keys::Set{String};
    ext = Dict{Symbol, Any}(), setting = Dict{String, Any}(),
    jump_model::JuMP.AbstractModel = JuMP.Model())
    @assert InfrastructureModel <: AbstractInfrastructureModel
    @assert ismultiinfrastructure(data) == true

    ref = ref_initialize(data, global_keys)
    var = _initialize_dict_from_ref(ref)
    con = _initialize_dict_from_ref(ref)
    sol = _initialize_dict_from_ref(ref)
    sol_proc = _initialize_dict_from_ref(ref)

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
        ext
    )

    return imo
end


"Constructor for an InfrastructureModels modeling object, where the
infrastructure type `it` must be specified a priori."
function InitializeInfrastructureModel(
    InfrastructureModel::Type, data::Dict{String, <:Any}, global_keys::Set{String},
    it::Symbol; ext = Dict{Symbol, Any}(), setting = Dict{String, Any}(),
    jump_model::JuMP.AbstractModel = JuMP.Model())
    @assert InfrastructureModel <: AbstractInfrastructureModel

    ref = ref_initialize(data, string(it), global_keys)
    var = _initialize_dict_from_ref(ref)
    con = _initialize_dict_from_ref(ref)
    sol = _initialize_dict_from_ref(ref)
    sol_proc = _initialize_dict_from_ref(ref)

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
        ext
    )

    return imo
end


"""
Given a data dictionary following the InfrastructureModels
multi-infrastructure conventions, build and return an initial "ref"
dictionary, converting strings to symbols and component keys to integers. The
global keys argument specifies which keys should remain in the root of the
dictionary when building the multi-infrastructure dataset.
"""
function ref_initialize(data::Dict{String, <:Any}, global_keys::Set{String} = Set{String}())
    # This variant of the function only operates on multiinfrastructure data.
    @assert ismultiinfrastructure(data) == true

    # Initialize the refs dictionary.
    refs = Dict{Symbol, Any}(:it => Dict{Symbol, Any}())

    for (it, data_it) in data["it"] # Iterate over all infrastructure types.
        # Populate the infrastructure section of the refs dictionary.
        _populate_ref_it!(refs, data_it, global_keys, it)

        # Populate the global keys section of the refs dictionary.
        _populate_ref_global_keys!(refs[:it][Symbol(it)], data_it, global_keys)
    end

    # Populate top-level dictionary global keys.
    _populate_ref_global_keys!(refs, data, global_keys)

    # Return the final refs object.
    return refs
end


"""
Given a data dictionary following the Infrastructure Models conventions, builds
an initial "ref" dictionary converting strings to symbols and component
keys to integers. The global keys argument specifies which keys should remain
in the root of dictionary when building a multi-network
"""
function ref_initialize(data::Dict{String, <:Any}, it::String, global_keys::Set{String} = Set{String}())
    # Initialize the refs dictionary.
    refs = Dict{Symbol, Any}(:it => Dict{Symbol, Any}())

    # Populate the infrastructure section of the refs dictionary.
    data_it = ismultiinfrastructure(data) ? data["it"][it] : data
    _populate_ref_it!(refs, data_it, global_keys, it)

    # Populate the global keys section of the refs dictionary.
    _populate_ref_global_keys!(refs[:it][Symbol(it)], data, global_keys)

    # Return the final refs object.
    return refs
end

"Initialize an empty dictionary with a structure similar to `ref`."
function _initialize_dict_from_ref(ref::Dict{Symbol, <:Any})
    dict = Dict{Symbol, Any}(:it => Dict{Symbol, Any}(), :dep => Dict{Symbol, Any}())
    dict[:it] = Dict{Symbol, Any}(it => Dict{Symbol, Any}() for it in keys(ref[:it]))

    for it in keys(ref[:it])
        dict[:it][it] = Dict{Symbol, Any}(:nw => Dict{Int, Any}())

        for nw in keys(ref[:it][it][:nw])
            dict[:it][it][:nw][nw] = Dict{Symbol, Any}()
        end
    end

    return dict
end


"Populate the portion of `refs` corresponding to global keys."
function _populate_ref_global_keys!(refs::Dict{Symbol, <:Any}, data::Dict{String, <:Any}, global_keys::Set{String} = Set{String}())
    # Populate the global keys section of the refs dictionary.
    for global_key in global_keys
        if haskey(data, global_key)
            refs[Symbol(global_key)] = data[global_key]
        end
    end
end


"Populate the portion of `refs` for a specific infrastructure type."
function _populate_ref_it!(refs::Dict{Symbol, <:Any}, data_it::Dict{String, <:Any}, global_keys::Set{String}, it::String)
    # Initialize the ref corresponding to the infrastructure type.
    refs[:it][Symbol(it)] = Dict{Symbol, Any}()

    # Build a multinetwork representation of the data.
    if ismultinetwork(data_it)
        nws_data = data_it["nw"]
    
        for (key, item) in data_it
            if key != "nw"
                refs[:it][Symbol(it)][Symbol(key)] = item
            end
        end
    else
        nws_data = Dict("0" => data_it)
    end

    nws = refs[:it][Symbol(it)][:nw] = Dict{Int, Any}()

    # Populate the specific infrastructure type's ref dictionary.
    for (n, nw_data) in nws_data
        nw_id = parse(Int, n)
        ref = nws[nw_id] = Dict{Symbol, Any}()
    
        for (key, item) in nw_data
            if !(key in global_keys)
                if isa(item, Dict{String, Any}) && _iscomponentdict(item)
                    item_lookup = Dict{Int, Any}([(parse(Int, k), v) for (k, v) in item])
                    ref[Symbol(key)] = item_lookup
                else
                    ref[Symbol(key)] = item
                end
            end
        end
    end
end


"Builds a ref object without the need to initialize an
AbstractInfrastructureModel, where `it` specifies the infrastructure type."
function build_ref(data::Dict{String,<:Any}, ref_add_core!, global_keys::Set{String}, it::String; ref_extensions=[])
    ref = ref_initialize(data, it, global_keys)
    ref_add_core!(ref)

    for ref_ext in ref_extensions
        ref_ext(ref, data)
    end

    return ref
end


"Builds a ref object without the need to initialize an
AbstractInfrastructureModel, where the data is assumed to be in a
multi-infrastructure format."
function build_ref(data::Dict{String,<:Any}, ref_add_core!, global_keys::Set{String}; ref_extensions=[])
    @assert ismultiinfrastructure(data)

    ref = ref_initialize(data, global_keys)
    ref_add_core!(ref)

    for ref_ext in ref_extensions
        ref_ext(ref, data)
    end

    return ref
end


report_duals(aim::AbstractInfrastructureModel) = haskey(aim.setting, "output") && haskey(aim.setting["output"], "duals") && aim.setting["output"]["duals"] == true

### Helper functions for working with AbstractInfrastructureModels
it_ids(aim::AbstractInfrastructureModel) = keys(aim.ref[:it])

function ismultiinfrastructure(aim::AbstractInfrastructureModel)
    return ismultiinfrastructure(aim.data)
end

function ismultinetwork(aim::AbstractInfrastructureModel, it::Symbol)
    data_it = ismultiinfrastructure(aim) ? aim.data["it"][string(it)] : aim.data
    return ismultinetwork(data_it)
end

nw_ids(aim::AbstractInfrastructureModel, it::Symbol) = keys(aim.ref[:it][it][:nw])
nws(aim::AbstractInfrastructureModel, it::Symbol) = aim.ref[:it][it][:nw]

ids(aim::AbstractInfrastructureModel, it::Symbol, nw::Int, key::Symbol) = keys(aim.ref[:it][it][:nw][nw][key])
ids(aim::AbstractInfrastructureModel, it::Symbol, key::Symbol; nw::Int=nw_id_default) = keys(aim.ref[:it][it][:nw][nw][key])


ref(aim::AbstractInfrastructureModel, it::Symbol, nw::Int) = aim.ref[:it][it][:nw][nw]
ref(aim::AbstractInfrastructureModel, it::Symbol, nw::Int, key::Symbol) = aim.ref[:it][it][:nw][nw][key]
ref(aim::AbstractInfrastructureModel, it::Symbol, nw::Int, key::Symbol, idx) = aim.ref[:it][it][:nw][nw][key][idx]
ref(aim::AbstractInfrastructureModel, it::Symbol, nw::Int, key::Symbol, idx, param::String) = aim.ref[:it][it][:nw][nw][key][idx][param]


ref(aim::AbstractInfrastructureModel, it::Symbol; nw::Int=nw_id_default) = aim.ref[:it][it][:nw][nw]
ref(aim::AbstractInfrastructureModel, it::Symbol, key::Symbol; nw::Int=nw_id_default) = aim.ref[:it][it][:nw][nw][key]
ref(aim::AbstractInfrastructureModel, it::Symbol, key::Symbol, idx; nw::Int=nw_id_default) = aim.ref[:it][it][:nw][nw][key][idx]
ref(aim::AbstractInfrastructureModel, it::Symbol, key::Symbol, idx, param::String; nw::Int=nw_id_default) = aim.ref[:it][it][:nw][nw][key][idx][param]

var(aim::AbstractInfrastructureModel, it::Symbol, nw::Int) = aim.var[:it][it][:nw][nw]
var(aim::AbstractInfrastructureModel, it::Symbol, nw::Int, key::Symbol) = aim.var[:it][it][:nw][nw][key]
var(aim::AbstractInfrastructureModel, it::Symbol, nw::Int, key::Symbol, idx) = aim.var[:it][it][:nw][nw][key][idx]

var(aim::AbstractInfrastructureModel, it::Symbol; nw::Int=nw_id_default) = aim.var[:it][it][:nw][nw]
var(aim::AbstractInfrastructureModel, it::Symbol, key::Symbol; nw::Int=nw_id_default) = aim.var[:it][it][:nw][nw][key]
var(aim::AbstractInfrastructureModel, it::Symbol, key::Symbol, idx; nw::Int=nw_id_default) = aim.var[:it][it][:nw][nw][key][idx]


con(aim::AbstractInfrastructureModel, it::Symbol, nw::Int) = aim.con[:it][it][:nw][nw]
con(aim::AbstractInfrastructureModel, it::Symbol, nw::Int, key::Symbol) = aim.con[:it][it][:nw][nw][key]
con(aim::AbstractInfrastructureModel, it::Symbol, nw::Int, key::Symbol, idx) = aim.con[:it][it][:nw][nw][key][idx]

con(aim::AbstractInfrastructureModel, it::Symbol; nw::Int=nw_id_default) = aim.con[:it][it][:nw][nw]
con(aim::AbstractInfrastructureModel, it::Symbol, key::Symbol; nw::Int=nw_id_default) = aim.con[:it][it][:nw][nw][key]
con(aim::AbstractInfrastructureModel, it::Symbol, key::Symbol, idx; nw::Int=nw_id_default) = aim.con[:it][it][:nw][nw][key][idx]


sol(aim::AbstractInfrastructureModel, it::Symbol, nw::Int, args...) = _sol(aim.sol[:it][it][:nw][nw], args...)
sol(aim::AbstractInfrastructureModel, it::Symbol, args...; nw::Int=nw_id_default) = _sol(aim.sol[:it][it][:nw][nw], args...)

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
function instantiate_model(
    data::Dict{String,<:Any}, model_type::Type, build_method, ref_add_core!,
    global_keys::Set{String}; ref_extensions=[], kwargs...)
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
function instantiate_model(
    data::Dict{String,<:Any}, model_type::Type, build_method, ref_add_core!,
    global_keys::Set{String}, it::Symbol; ref_extensions=[], kwargs...)
    # NOTE, this model constructor will build the ref dict using the latest info from the data    
    start_time = time()

    imo = InitializeInfrastructureModel(model_type, data, global_keys, it; kwargs...)

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
function optimize_model!(aim::AbstractInfrastructureModel; relax_integrality=false, optimizer=nothing, solution_processors=[])
    start_time = time()

    if relax_integrality
        JuMP.relax_integrality(aim.model)
    end

    if JuMP.mode(aim.model) != JuMP.DIRECT && optimizer !== nothing
        if aim.model.moi_backend.state == _MOI.Utilities.NO_OPTIMIZER
            JuMP.set_optimizer(aim.model, optimizer)
        else
            Memento.warn(_LOGGER, "Model already contains optimizer, cannot use optimizer specified in `optimize_model!`")
        end
    end

    if JuMP.mode(aim.model) != JuMP.DIRECT && aim.model.moi_backend.state == _MOI.Utilities.NO_OPTIMIZER
        Memento.error(_LOGGER, "No optimizer specified in `optimize_model!` or the given JuMP model.")
    end

    _, solve_time, solve_bytes_alloc, sec_in_gc = @timed JuMP.optimize!(aim.model)

    try
        solve_time = JuMP.solve_time(aim.model)
    catch
        Memento.warn(_LOGGER, "The given optimizer does not provide the SolveTime() attribute, falling back on @timed.  This is not a rigorous timing value.");
    end
    
    Memento.debug(_LOGGER, "JuMP model optimize time: $(time() - start_time)")

    start_time = time()
    result = build_result(aim, solve_time; solution_processors=solution_processors)
    Memento.debug(_LOGGER, "solution build time: $(time() - start_time)")

    aim.solution = result["solution"]

    return result
end
