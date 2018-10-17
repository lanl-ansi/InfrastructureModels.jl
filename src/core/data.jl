export update_data!

"recursively applies new_data to data, overwriting information"
function update_data!(data::Dict{String,Any}, new_data::Dict{String,Any})
    if haskey(data, "per_unit") && haskey(new_data, "per_unit")
        if data["per_unit"] != new_data["per_unit"]
            error("update_data requires datasets in the same units, try make_per_unit and make_mixed_units")
        end
    else
        warn(LOGGER, "running update_data with data that does not include per_unit field, units may be incorrect")
    end
    _update_data!(data, new_data)
end


"recursive call of _update_data"
function _update_data!(data::Dict{String,Any}, new_data::Dict{String,Any})
    for (key, new_v) in new_data
        if haskey(data, key)
            v = data[key]
            if isa(v, Dict) && isa(new_v, Dict)
                _update_data!(v, new_v)
            else
                data[key] = new_v
            end
        else
            data[key] = new_v
        end
    end
end

"checks if a given network data is a multinetwork"
ismultinetwork(data::Dict{String,Any}) = (haskey(data, "multinetwork") && data["multinetwork"] == true)

"Transforms a single network into a multinetwork with several deepcopies of the original network"
function replicate(sn_data::Dict{String,Any}, count::Int)
    @assert count > 0
    if ismultinetwork(sn_data)
        error("replicate can only be used on single networks")
    end

    name = get(sn_data, "name", "anonymous")

    mn_data = Dict{String,Any}(
        "nw" => Dict{String,Any}()
    )

    global_keys = Set()
    for (k,v) in sn_data
        # Question: should this only copy component lists?
        if !(typeof(v) <: Dict)
            mn_data[k] = deepcopy(v)
            push!(global_keys, k)
        end
    end

    mn_data["multinetwork"] = true
    mn_data["name"] = "$(count) replicates of $(name)"

    sn_data_tmp = deepcopy(sn_data)
    for k in global_keys
        delete!(sn_data_tmp, k)
    end

    for n in 1:count
        mn_data["nw"]["$n"] = deepcopy(sn_data_tmp)
    end

    return mn_data
end



"builds a table of component data"
function component_table(data::Dict{String,Any}, component::String, fields::Vector{String})
    if ismultinetwork(data)
        return Dict((i, _component_table(nw_data, component, fields)) for (i,nw_data) in data["nw"])
    else
        return _component_table(data, component, fields)
    end
end
component_table(data::Dict{String,Any}, component::String, field::String) = component_table(data, component, [field])

function _component_table(data::Dict{String,Any}, component::String, fields::Vector{String})
    comps = data[component]
    if !_iscomponentdict(comps)
        error(LOGGER, "$(component) does not appear to refer to a component list")
    end

    items = []
    sorted_comps = sort(collect(comps); by=x->parse(Int, x[1]))
    for (i,comp) in sorted_comps
        push!(items, parse(Int, i))
    end
    for key in fields
        for (i,comp) in sorted_comps
            if haskey(comp, key)
                push!(items, comp[key])
            else
                push!(items, NaN)
            end
        end
    end

    return reshape(items, length(comps), length(fields)+1)
end


"prints the text summary for a data dictionary to STDOUT"
function print_summary(obj::Dict{String,Any}; kwargs...)
    summary(STDOUT, obj; kwargs...)
end


"prints the text summary for a data dictionary to IO"
function summary(io::IO, data::Dict{String,Any}; float_precision::Int = 3)
    if ismultinetwork(data)
        error("summary does not yet support multinetwork data")
    end

    component_types_order = Dict(
        "bus" => 1.0, "load" => 2.0, "shunt" => 3.0, "gen" => 4.0,
        "branch" => 5.0, "dcline" => 6.0
    )

    component_parameter_order = Dict(
        "bus_i" => 1.0, "load_bus" => 2.0, "shunt_bus" => 3.0, "gen_bus" => 4.0,
        "f_bus" => 5.0, "t_bus" => 6.0,

        "bus_name" => 9.1, "base_kv" => 9.2, "bus_type" => 9.3,

        "vm" => 10.0, "va" => 11.0,
        "pd" => 20.0, "qd" => 21.0,
        "gs" => 30.0, "bs" => 31.0,
        "pg" => 40.0, "qg" => 41.0, "vg" => 42.0, "mbase" => 43.0,
        "br_r" => 50.0, "br_x" => 51.0, "g_fr" => 52.0, "b_fr" => 53.0,
        "g_to" => 54.0, "b_to" => 55.0, "tap" => 56.0, "shift" => 57.0,
        "vf" => 58.1, "pf" => 58.2, "qf" => 58.3,
        "vt" => 58.4, "pt" => 58.5, "qt" => 58.6,
        "loss0" => 58.7, "loss1" => 59.8,

        "vmin" => 60.0, "vmax" => 61.0,
        "pmin" => 62.0, "pmax" => 63.0,
        "qmin" => 64.0, "qmax" => 65.0,
        "rate_a" => 66.0, "rate_b" => 67.0, "rate_c" => 68.0,
        "pminf" => 69.0, "pmaxf" => 70.0, "qminf" => 71.0, "qmaxf" => 72.0,
        "pmint" => 73.0, "pmaxt" => 74.0, "qmint" => 75.0, "qmaxt" => 76.0,

        "status" => 80.0, "gen_status" => 81.0, "br_status" => 82.0,

        "model" => 90.0, "ncost" => 91.0, "cost" => 92.0, "startup" => 93.0, "shutdown" => 94.0
    )
    max_parameter_value = 999.0

    component_status_parameters = Set(["status", "gen_status", "br_status", "bus_type"])


    component_types = []
    other_types = []

    println(io, _bold("Metadata"))
    for (k,v) in sort(collect(data); by=x->x[1])
        if typeof(v) <: Dict && _iscomponentdict(v)
            push!(component_types, k)
            continue
        end

        println(io, "  $(k): $(_value2string(v, float_precision))")
    end


    if length(component_types) > 0
        println(io, "")
        println(io, _bold("Table Counts"))
    end
    for k in sort(component_types, by=x->get(component_types_order, x, 999))
        println(io, "  $(k): $(length(data[k]))")
    end

    for comp_type in sort(component_types, by=x->get(component_types_order, x, 999))
        if length(data[comp_type]) <= 0
            continue
        end
        println(io, "")
        println(io, "")
        println(io, _bold("Table: $(comp_type)"))

        components = data[comp_type]

        display_components = Dict()
        active_components = Set()
        for (i, component) in components
            disp_comp = copy(component)

            status_found = false
            for (k, v) in disp_comp
                if k in component_status_parameters
                    status_found = true
                    if !(v == 0 || v == 4)
                        push!(active_components, i)
                    end
                end

                disp_comp[k] = _value2string(v, float_precision)
            end
            if !status_found
                push!(active_components, i)
            end

            display_components[i] = disp_comp
        end


        comp_key_sizes = Dict{String, Int}()
        default_values = Dict{String, Any}()
        for (i, component) in display_components
            # a special case for "index", for example when reading solution data
            if haskey(comp_key_sizes, "index")
                comp_key_sizes["index"] = max(comp_key_sizes["index"], length(i))
            else
                comp_key_sizes["index"] = length(i)
            end

            for (k, v) in component
                if haskey(comp_key_sizes, k)
                    comp_key_sizes[k] = max(comp_key_sizes[k], length(v))
                else
                    comp_key_sizes[k] = length(v)
                end

                if haskey(default_values, k)
                    if default_values[k] != v
                        default_values[k] = nothing
                    end
                else
                    default_values[k] = v
                end
            end
        end

        # when there is only one component nothing is default
        if length(display_components) == 1
            default_values = Dict{String, Any}()
        else
            default_values = Dict{String, Any}([x for x in default_values if !isa(x.second, Nothing)])
        end

        #display(default_values)

        # account for header width
        for (k, v) in comp_key_sizes
            comp_key_sizes[k] = max(length(k), v)
        end

        comp_id_pad = comp_key_sizes["index"] # not clear why this is offset so much
        delete!(comp_key_sizes, "index")
        comp_keys_ordered = sort([k for k in keys(comp_key_sizes) if !(haskey(default_values, k))], by=x->(get(component_parameter_order, x, max_parameter_value), x))

        header = join([lpad(k, comp_key_sizes[k]) for k in comp_keys_ordered], ", ")

        pad = " "^(comp_id_pad+2)
        println(io, "  $(pad)$(header)")
        for k in sort([k for k in keys(display_components)]; by=x->parse(Int, x))
            comp = display_components[k]
            items = []
            for ck in comp_keys_ordered
                if haskey(comp, ck)
                    push!(items, lpad("$(comp[ck])", comp_key_sizes[ck]))
                else
                    push!(items, lpad("--", comp_key_sizes[ck]))
                end
            end
            line = "  $(lpad(k, comp_id_pad)): $(join(items, ", "))"
            if k in active_components
                println(io, line)
            else
                println(io, _grey(line))
            end
        end

        if length(default_values) > 0
            println(io, "")
            println(io, "  default values:")
            for k in sort([k for k in keys(default_values)], by=x->(get(component_parameter_order, x, max_parameter_value), x))
                println(io, "    $(k): $(default_values[k])")
            end
        end
    end

end

"Attempts to determine if the given data is a component dictionary"
function _iscomponentdict(data::Dict)
    return all( typeof(comp) <: Dict for (i, comp) in data )
end

"Makes a string bold in the terminal"
function _bold(s::String)
    return "\033[1m$(s)\033[0m"
end

"""
Makes a string grey in the terminal, does not seem to work well on Windows terminals
more info can be found at https://en.wikipedia.org/wiki/ANSI_escape_code
"""
function _grey(s::String)
    return "\033[38;5;239m$(s)\033[0m"
end

"converts any value to a string, summarizes arrays and dicts"
function _value2string(v, float_precision::Int)
    if typeof(v) <: AbstractFloat
        return _float2string(v, float_precision)
    end
    if typeof(v) <: Array
        return "[($(length(v)))]"
    end
    if typeof(v) <: Dict
        return "{($(length(v)))}"
    end

    return "$(v)"
end


"""
converts a float value into a string of fixed precision

sprintf would do the job but this work around is needed because
sprintf cannot take format strings during runtime
"""
function _float2string(v::AbstractFloat, float_precision::Int)
    #str = "$(round(v; digits=float_precision))"
    str = "$(round(v; digits=float_precision))"
    lhs = length(split(str, '.')[1])
    return rpad(str, lhs + 1 + float_precision, "0")
end



"tests if two dicts are equal, up to floating point precision"
function compare_dict(d1, d2)
    for (k1,v1) in d1
        if !haskey(d2, k1)
            #println(k1)
            return false
        end
        v2 = d2[k1]

        if isa(v1, Number)
            if !compare_numbers(v1, v2)
                return false
            end
        elseif isa(v1, Array)
            if length(v1) != length(v2)
                return false
            end
            for i in 1:length(v1)
                if isa(v1[i], Number)
                    if !compare_numbers(v1[i], v2[i])
                        return false
                    end
                else
                    if v1 != v2
                        #println(v1, " ", v2)
                        return false
                    end
                end
            end
        elseif isa(v1, Dict)
            if !compare_dict(v1, v2)
                #println(v1, " ", v2)
                return false
            end
        else
            #println("2")
            if !isapprox(v1, v2)
                #println(v1, " ", v2)
                return false
            end
        end
    end
    return true
end

function Base.isapprox(a::Any, b::Any; kwargs...)
    return a == b
end

"tests if two numbers are equal, up to floating point precision"
function compare_numbers(v1, v2)
    if isnan(v1)
        #println("1.1")
        if !isnan(v2)
            #println(v1, " ", v2)
            return false
        end
    else
        #println("1.2")
        if !isapprox(v1, v2)
            #println(v1, " ", v2)
            return false
        end
    end
    return true
end

