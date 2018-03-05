
@testset "parsing simple matlab file" begin
    data = parse_matlab_file("../test/data/matlab_01.m")

    @test length(data) == 6
    @test length(data["mpc.bus"]) == 2
    @test length(data["mpc.gen"]) == 1
    @test length(data["mpc.branch"]) == 1

    @test isa(data["mpc.version"], SubString{String})
    @test isa(data["mpc.baseMVA"], Float64)

    @test data["mpc.gen"][1][2] == 1098.17
end

@testset "parsing complex matlab file" begin
    data = parse_matlab_file("../test/data/matlab_02.m")

    @test length(data) == 16
    @test length(data["mpc.bus"]) == 3
    @test length(data["mpc.gen"]) == 3
    @test length(data["mpc.branch"]) == 3
    @test length(data["mpc.branch_limit"]) == 3

    @test length(data["mpc.areas"][1]) == 2
    @test length(data["mpc.branch_limit"][1]) == 2

    @test isa(data["mpc.version"], SubString{String})
    @test isa(data["mpc.baseMVA"], Float64)
    @test isa(data["mpc.const_str"], SubString{String})

    @test data["mpc.areas_cells"][1][1] == "Area 1"
    @test data["mpc.areas_cells"][1][3] == 987
end

@testset "parsing matlab extended features" begin
    data, func, columns = parse_matlab_file("../test/data/matlab_02.m", extended=true)

    @test func == "matlab_02"

    @test length(columns) == 4

    @test columns["mpc.areas_named"][2] == "refbus"

    for (k,v) in columns
        @test haskey(data, k)
        @test length(data[k][1]) == length(v)
    end
end
