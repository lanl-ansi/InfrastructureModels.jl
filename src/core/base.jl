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


"Attempts to determine if the given data is a component dictionary"
function _iscomponentdict(data::Dict)
    return all( typeof(comp) <: Dict for (i, comp) in data )
end