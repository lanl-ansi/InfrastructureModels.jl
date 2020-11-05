@testset "matlab parsing" begin

    @testset "parsing simple matlab file" begin
        data = parse_matlab_file("../test/data/matlab_01.m")

        @test length(data) == 6
        @test length(data["mpc.bus"]) == 2
        @test length(data["mpc.gen"]) == 1
        @test length(data["mpc.branch"]) == 1
        @test InfrastructureModels.get_num_networks(data) == 1
        @test InfrastructureModels.has_time_series(data) == false

        @test isa(data["mpc.version"], SubString{String})
        @test isa(data["mpc.baseMVA"], Float64)

        @test data["mpc.gen"][1][2] == 1098.17
    end

    @testset "parsing complex matlab file" begin
        data = parse_matlab_file("../test/data/matlab_02.m")

        @test length(data) == 17
        @test length(data["mpc.bus"]) == 3
        @test length(data["mpc.gen"]) == 3
        @test length(data["mpc.branch"]) == 3
        @test length(data["mpc.branch_limit"]) == 3

        @test length(data["mpc.areas"][1]) == 2
        @test length(data["mpc.branch_limit"][1]) == 2
        @test length(data["mpc.zones_named"][1]) == 3

        @test isa(data["mpc.version"], SubString{String})
        @test isa(data["mpc.baseMVA"], Float64)
        @test isa(data["mpc.const_str"], SubString{String})

        @test data["mpc.areas_cells"][1][1] == "Area 1"
        @test data["mpc.areas_cells"][1][3] == 987
    end

    @testset "parsing matlab struct name" begin
        data = parse_matlab_file("../test/data/matlab_03.m")

        @test length(data) == 8
        @test length(data["udc.bus"]) == 3
        @test length(data["udc.gen"]) == 3
        @test length(data["udc.branch"]) == 3

        @test isa(data["udc.version"], SubString{String})
        @test isa(data["udc.baseMVA"], Float64)

        @test isa(data["bloop.baseMVA"], Float64)
    end

    @testset "parsing matlab extended features" begin
        data, func, columns = parse_matlab_file("../test/data/matlab_02.m", extended=true)

        @test func == "matlab_02"

        @test length(columns) == 5

        @test columns["mpc.areas_named"][2] == "refbus"
        @test columns["mpc.zones_named"][1] == "index"

        for (k,v) in columns
            @test haskey(data, k)
            @test length(data[k][1]) == length(v)
        end
    end
end


@testset "data summary" begin

    @testset "summary feature non-standard dict structure" begin
        data = Dict(
            "a" => 1,
            "b" => [1, 2, 3],
            "c" => Dict(
                "e" => 1.2,
                "d" => 2.3
            )
        )

        output = sprint(InfrastructureModels.summary, data)

        line_count = count(c -> c == '\n', output)
        @test line_count >= 3 && line_count <= 6
        @test occursin("Metadata", output)
        @test occursin("a: 1", output)
        @test occursin("b: [(3)]", output)
        @test occursin("c: {(2)}",output)
    end

    @testset "summary feature matlab data" begin
        data = parse_matlab_file("../test/data/matlab_01.m")

        output = sprint(InfrastructureModels.summary, data)

        line_count = count(c -> c == '\n', output)
        @test line_count >= 5 && line_count <= 10
        @test occursin( "mpc.baseMVA", output)
        @test occursin( "mpc.version", output)
        @test occursin( "mpc.bus_name: [(2)]", output)
    end

    @testset "summary feature component data" begin
        output = sprint(InfrastructureModels.summary, generic_network_data["it"]["foo"])

        line_count = count(c -> c == '\n', output)
        @test line_count >= 18 && line_count <= 22
        @test occursin("dict: {(4)}", output)
        @test occursin("list: [(4)]", output)
        @test occursin("default values:", output)
        @test occursin("Table Counts", output)
        @test occursin("Table: comp", output)
        @test occursin("d,", output) # correct presentation of sparse non-default value
    end

end

@testset "data component table" begin

    @testset "single network" begin
        data = parse_matlab_file("../test/data/matlab_02.m")

        rows_to_dict!(data)
        InfrastructureModels.arrays_to_dicts!(data)

        ct1 = InfrastructureModels.component_table(data, "mpc.bus", "col_3")
        @test length(ct1) == 6
        @test size(ct1,1) == 3
        @test size(ct1,2) == 2

        ct2 = InfrastructureModels.component_table(data, "mpc.bus", ["col_2", "col_4"])
        @test length(ct2) == 9
        @test size(ct2,1) == 3
        @test size(ct2,2) == 3

        ct3 = InfrastructureModels.component_table(data, "mpc.gen", ["col_2", "col_4"])
        @test length(ct3) == 9
        @test size(ct3,1) == 3
        @test size(ct3,2) == 3

        ct4 = InfrastructureModels.component_table(data, "mpc.branch", ["col_2", "col_4", "col_6"])
        @test length(ct4) == 12
        @test size(ct4,1) == 3
        @test size(ct4,2) == 4
    end

    @testset "mixed data types" begin
        data = parse_matlab_file("../test/data/matlab_02.m")

        rows_to_dict!(data)
        InfrastructureModels.arrays_to_dicts!(data)

        for (i,bus) in data["mpc.bus"]
            bus["name"] = "bus_$(i)"
        end

        ct1 = InfrastructureModels.component_table(data, "mpc.bus", ["col_2", "col_4", "name"])
        @test length(ct1) == 12
        @test size(ct1,1) == 3
        @test size(ct1,2) == 4
    end

    @testset "multi network" begin
        data = parse_matlab_file("../test/data/matlab_02.m")

        rows_to_dict!(data)
        InfrastructureModels.arrays_to_dicts!(data)

        mn_data = InfrastructureModels.replicate(data, 3, Set{String}())

        ct1 = InfrastructureModels.component_table(mn_data, "mpc.bus", "col_3")
        for (i, nw) in mn_data["nw"]
            @test length(ct1[i]) == 6
            @test size(ct1[i],1) == 3
            @test size(ct1[i],2) == 2
        end

        ct2 = InfrastructureModels.component_table(mn_data, "mpc.bus", ["col_2", "col_4"])
        for (i, nw) in mn_data["nw"]
            @test length(ct2[i]) == 9
            @test size(ct2[i],1) == 3
            @test size(ct2[i],2) == 3
        end

        ct3 = InfrastructureModels.component_table(mn_data, "mpc.gen", ["col_2", "col_4"])
        for (i, nw) in mn_data["nw"]
            @test length(ct3[i]) == 9
            @test size(ct3[i],1) == 3
            @test size(ct3[i],2) == 3
        end

        ct4 = InfrastructureModels.component_table(mn_data, "mpc.branch", ["col_2", "col_4", "col_6"])
        for (i, nw) in mn_data["nw"]
            @test length(ct4[i]) == 12
            @test size(ct4[i],1) == 3
            @test size(ct4[i],2) == 4
        end
    end

end


@testset "data transformation" begin

    @testset "network replicate data" begin
        mn_data = InfrastructureModels.replicate(generic_network_data["it"]["foo"], 3, Set(["a", "b", "per_unit", "list"]))

        @test InfrastructureModels.get_num_networks(mn_data) == 3
        @test length(mn_data) == 7
        @test mn_data["multinetwork"]
        @test haskey(mn_data, "per_unit")
        @test haskey(mn_data, "name")

        @test haskey(mn_data, "a")
        @test haskey(mn_data, "b")
        @test haskey(mn_data, "list")

        @test length(mn_data["nw"]) == 3
        @test mn_data["nw"]["1"] == mn_data["nw"]["2"]
        @test mn_data["nw"]["2"] == mn_data["nw"]["3"]
    end


    @testset "network replicate data, single network" begin
        mn_data = InfrastructureModels.replicate(generic_network_data["it"]["foo"], 1, Set(["per_unit","undefined_key"]))

        @test length(mn_data) == 4
        @test mn_data["multinetwork"]
        @test haskey(mn_data, "per_unit")
        @test haskey(mn_data, "name")

        @test length(mn_data["nw"]) == 1
    end


   @testset "load state from time series" begin
        data_tmp = deepcopy(generic_network_data)
        data_tmp["it"]["foo"]["time_series"] = generic_network_time_series_data
        @test data_tmp["it"]["foo"]["comp"]["1"]["a"] == 1
        @test data_tmp["it"]["foo"]["comp"]["2"]["c"] == "same"

        InfrastructureModels.load_timepoint!(data_tmp["it"]["foo"], 1)
        @test data_tmp["it"]["foo"]["comp"]["1"]["a"] == 3
        @test data_tmp["it"]["foo"]["comp"]["2"]["c"] == "three"

        InfrastructureModels.load_timepoint!(data_tmp["it"]["foo"], 2)
        @test data_tmp["it"]["foo"]["comp"]["1"]["a"] == 5
        @test data_tmp["it"]["foo"]["comp"]["2"]["c"] == "five"

        InfrastructureModels.load_timepoint!(data_tmp["it"]["foo"], 3)
        @test data_tmp["it"]["foo"]["comp"]["1"]["a"] == 7
        @test data_tmp["it"]["foo"]["comp"]["2"]["c"] == "seven"
    end


    @testset "make_multinetwork from time series" begin
        generic_network_data_tmp = deepcopy(generic_network_data)
        generic_network_data_tmp["it"]["foo"]["time_series"] = generic_network_time_series_data
        @test InfrastructureModels.get_num_networks(generic_network_data_tmp["it"]["foo"]) == 3
        @test InfrastructureModels.has_time_series(generic_network_data_tmp["it"]["foo"]) == true
        mn_data = InfrastructureModels.make_multinetwork(generic_network_data_tmp, "foo", Set(["per_unit","undefined_key"]))
        mn_data_it = mn_data["it"]["foo"]

        @test length(mn_data_it) == 5
        @test mn_data_it["multinetwork"]
        @test haskey(mn_data_it, "per_unit")
        @test haskey(mn_data_it, "name")
        @test haskey(mn_data_it, "global_constant")
        @test isapprox(mn_data_it["global_constant"], 2.71, atol=1e-1)

        @test length(mn_data_it["nw"]) == 3

        @test mn_data_it["nw"]["1"]["comp"]["1"]["a"] == 3
        @test mn_data_it["nw"]["1"]["comp"]["2"]["c"] == "three"
        @test mn_data_it["nw"]["1"]["time"] == 0.0

        @test mn_data_it["nw"]["2"]["comp"]["1"]["a"] == 5
        @test mn_data_it["nw"]["2"]["comp"]["2"]["c"] == "five"
        @test mn_data_it["nw"]["2"]["time"] == 1.0

        @test mn_data_it["nw"]["3"]["comp"]["1"]["a"] == 7
        @test mn_data_it["nw"]["3"]["comp"]["2"]["c"] == "seven"
        @test mn_data_it["nw"]["3"]["time"] == 2.0
    end


    @testset "update_data! feature" begin
        data = JSON.parse("{
            \"per_unit\":false,
            \"a\":1,
            \"b\":\"bloop\",
            \"c\":{
                \"1\":{
                    \"a\":2,
                    \"b\":3
                },
                \"3\":{
                    \"a\":2,
                    \"b\":3
                }
            }
        }")

        mod = JSON.parse("{
            \"per_unit\":false,
            \"e\":1.23,
            \"b\":[4,5,6],
            \"c\":{
                \"1\":{
                    \"a\":4,
                    \"b\":\"bloop\"
                },
                \"2\":{
                    \"a\":4,
                    \"b\":false
                }
            }
        }")

        update_data!(data, mod)

        @test length(data) == 5
        @test data["a"] == 1
        @test data["b"][2] == 5
        @test length(data["c"]) == 3
        @test data["e"] == 1.23

        @test data["c"]["1"]["a"] == 4
        @test data["c"]["1"]["b"] == "bloop"

        @test data["c"]["2"]["a"] == 4
        @test data["c"]["2"]["b"] == false

        @test data["c"]["3"]["a"] == 2
        @test data["c"]["3"]["b"] == 3
    end


    @testset "transform dict-of-arrays to dict-of-dicts" begin
        data = parse_matlab_file("../test/data/matlab_01.m")

        data["mpc.tmp"] = []

        rows_to_dict!(data)

        InfrastructureModels.arrays_to_dicts!(data)

        @test length(data) == 7
        @test length(data["mpc.bus"]) == 2
        @test length(data["mpc.gen"]) == 1
        @test length(data["mpc.branch"]) == 1

        @test isa(data["mpc.version"], SubString{String})
        @test isa(data["mpc.baseMVA"], Float64)
        @test isa(data["mpc.bus"], Dict{String,Any})
        @test isa(data["mpc.gen"], Dict{String,Any})
        @test isa(data["mpc.branch"], Dict{String,Any})
        @test isa(data["mpc.bus_name"], Dict{String,Any})

        @test data["mpc.gen"]["1"]["col_2"] == 1098.17
    end

    @testset "transform an array into a typed dict" begin
        data = parse_matlab_file("../test/data/matlab_03.m")

        bus_columns = [
            ("bus_i", Int),
            ("bus_type", Int),
            ("pd", Float64), ("qd", Float64),
            ("gs", Float64), ("bs", Float64),
            ("area", Int),
            ("vm", Float64), ("va", Float64),
            ("base_kv", Float64),
            ("zone", Complex)
        ]

        buses = []
        for bus_row in data["udc.bus"]
            bus_data = InfrastructureModels.row_to_typed_dict(bus_row, bus_columns)
            push!(buses, bus_data)
        end

        @test length(buses) == length(data["udc.bus"])

        bus = buses[1]

        @test bus["bus_i"] == 1
        @test bus["qd"] == 40.0
        @test bus["zone"] == 1 + 0im
        @test bus["col_12"] == 1.1

        @test typeof(bus["bus_i"]) == Int64
        @test typeof(bus["qd"]) == Float64
        @test typeof(bus["zone"]) == Complex{Int64}
        @test typeof(bus["col_12"]) == Float64

    end

    @testset "transform an array into a dict" begin
        data = parse_matlab_file("../test/data/matlab_03.m")

        bus_columns = [
            "bus_i",
            "bus_type",
            "pd", "qd",
            "gs", "bs",
            "area",
            "vm", "va",
            "base_kv",
            "zone"
        ]

        buses = []
        for bus_row in data["udc.bus"]
            bus_data = InfrastructureModels.row_to_dict(bus_row, bus_columns)
            push!(buses, bus_data)
        end

        @test length(buses) == length(data["udc.bus"])

        bus = buses[1]

        @test bus["bus_i"] == 1
        @test bus["qd"] == 40.0
        @test bus["zone"] == 1
        @test bus["col_12"] == 1.1

        @test typeof(bus["bus_i"]) == Int64
        @test typeof(bus["qd"]) == Float64
        @test typeof(bus["zone"]) == Int64
        @test typeof(bus["col_12"]) == Float64

    end
end


@testset "data comparison" begin

    @testset "dict comparison" begin
        mn_data = InfrastructureModels.replicate(generic_network_data["it"]["foo"], 3, Set{String}())

        nw_1 = mn_data["nw"]["1"]
        nw_2 = mn_data["nw"]["2"]
        nw_3 = mn_data["nw"]["3"]

        nw_1["dict"]["b"] = 2.00000001

        @test InfrastructureModels.compare_dict(nw_1, nw_2)
        @test InfrastructureModels.compare_dict(nw_1, nw_3)
    end

end
