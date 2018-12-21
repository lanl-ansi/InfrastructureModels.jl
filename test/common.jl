
generic_network_data = JSON.parse("""{
    "per_unit":false,
    "a":1,
    "b":"bloop",
    "list": [1, "two", 3.0, false],
    "dict": {"a":1, "b":2.0, "c":true, "d":"bloop"},
    "comp":{
        "1":{
            "a":1,
            "b":2,
            "c":"same",
            "status":1
        },
        "2":{
            "a":3,
            "b":4,
            "c":"same",
            "status":0
        },
        "3":{
            "a":5,
            "b":6,
            "c":"same"
        }
    }
}""")


function rows_to_dict!(data::Dict{String,Any})
    for (k,v) in data
        if isa(v, Array)
            items = Array{Any,1}()

            for item in v
                dict = InfrastructureModels.row_to_dict(item)
                push!(items, dict)
            end

            data[k] = items
        end
    end
end
