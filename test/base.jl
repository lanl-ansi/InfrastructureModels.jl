
@def some_fields begin
    i::Int64
    f::Float64
    s::String
end

abstract type AbstractModel end

mutable struct FooModel <: AbstractModel @some_fields end
mutable struct BarModel <: AbstractModel @some_fields end

@testset "def macro" begin
    foo = FooModel(1, 2.3, "4")
    bar = BarModel(1, 2.3, "4")

    @test foo.i == bar.i
    @test foo.f == bar.f
    @test foo.s == bar.s
end


@testset "ref initialize" begin
    ref = ref_initialize(generic_network_data)

    @test !haskey(ref, :dict)
    @test !haskey(ref, :per_unit)

    @test ref[:nw][0][:a] == 1
    @test ref[:nw][0][:b] == "bloop"
    @test ref[:nw][0][:per_unit] == false
    @test ref[:nw][0][:dict]["b"] == 2.0
    @test ref[:nw][0][:comp][2]["a"] == 3
end

@testset "ref initialize with global keys" begin
    ref = ref_initialize(generic_network_data, Set(["per_unit", "dict"]))

    @test ref[:per_unit] == false
    @test ref[:dict]["b"] == 2.0

    @test !haskey(ref[:nw][0], :dict)
    @test !haskey(ref[:nw][0], :per_unit)
    @test ref[:nw][0][:a] == 1
    @test ref[:nw][0][:b] == "bloop"
    @test ref[:nw][0][:comp][2]["a"] == 3
end
