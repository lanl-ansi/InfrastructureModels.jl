

"turns top level arrays into dicts"
function arrays_to_dicts(data::Dict{String,Any})
    # update lookup structure
    for (k,v) in data
        if isa(v, Array)
            #println("updating $(k)")
            dict = Dict{String,Any}()
            for item in v
                assert("index" in keys(item))
                key = string(item["index"])
                if !(haskey(dict, key))
                    dict[key] = item
                else
                    warn(LOGGER, "skipping component $(item["index"]) from the $(k) table because a component with the same id already exists")
                end
            end
            data[k] = dict
        end
    end
end

