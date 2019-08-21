
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
