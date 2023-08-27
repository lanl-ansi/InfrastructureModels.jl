
gn_global_keys = Set(["per_unit","undefined_key"])

generic_si_network_data = JSON.parse("""{
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
            "c":"same",
            "d":false
        }
    }
}""")

# used to check that ref_initialize works correctly with strongly typed data
generic_si_network_data_native = Dict(
    "per_unit" => false,
    "a" => 1,
    "b" => "bloop",
    "list" =>  [1, "two", 3.0, false],
    "dict" =>  Dict("a" => 1, "b" => 2.0, "c" => true, "d" => "bloop"),
    "comp" => Dict(
        "1" => Dict(
            "a" => 1,
            "b" => 2,
            "c" => "same",
            "status" => 1
        ),
        "2" => Dict(
            "a" => 3,
            "b" => 4,
            "c" => "same",
            "status" => 0
        ),
        "3" => Dict(
            "a" => 5,
            "b" => 6,
            "c" => "same",
            "d" => false
        )
    )
)

generic_mi_network_data = JSON.parse("""
{
    "multiinfrastructure": true,
    "it": {
        "foo": {
            "per_unit": false,
            "a": 1,
            "b": "bloop",
            "list": [1, "two", 3.0, false],
            "dict": {"a":1, "b":2.0, "c":true, "d":"bloop"},
            "comp": {
                "1": {
                    "a": 1,
                    "b": 2,
                    "c": "same",
                    "status": 1
                },
                "2": {
                    "a": 3,
                    "b": 4,
                    "c": "same",
                    "status": 0
                },
                "3": {
                    "a": 5,
                    "b": 6,
                    "c": "same",
                    "d": false
                }
            }
        },
        "dep": {
            "property_1": 1.0,
            "property_2": "bar",
            "placeholder_dep_comp": {
                "5": {
                    "property_3": 1.0,
                    "property_4": "foo"
                },
                "6": {
                    "property_3": 2.0,
                    "property_4": "barbar"
                }
            }
        }
    }
}""")

generic_network_time_series_data = Dict(
    "num_steps" => 3,
    "global_constant" => 2.71,
    "time" => [0.0, 1.0, 2.0],
    "comp" => Dict(
        "1" => Dict("a" => [3, 5, 7]),
        "2" => Dict("c" => ["three", "five", "seven"])
    )
)


function rows_to_dict!(data::Dict{String,<:Any})
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
