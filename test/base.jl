
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


abstract type MyAbstractInfrastructureModel <: AbstractInfrastructureModel end
mutable struct MyInfrastructureModel <: MyAbstractInfrastructureModel @im_fields end

@testset "@im_fields and InitializeInfrastructureModel" begin
    global_keys = Set{String}()
    mim = InitializeInfrastructureModel(MyInfrastructureModel, generic_network_data, global_keys)

    @test isa(mim.model, JuMP.AbstractModel)

    @test length(mim.data) == 7
    @test length(mim.setting) == 0
    @test length(mim.solution) == 0
    @test length(mim.ext) == 0

    @test mim.cnw == 0

    @test haskey(mim.ref, :nw); @test length(mim.ref[:nw][mim.cnw]) == 7
    @test haskey(mim.var, :nw); @test length(mim.var[:nw][mim.cnw]) == 0
    @test haskey(mim.con, :nw); @test length(mim.con[:nw][mim.cnw]) == 0
    @test haskey(mim.sol, :nw); @test length(mim.sol[:nw][mim.cnw]) == 0

    @test haskey(mim.sol_proc, :nw); @test length(mim.sol_proc[:nw][mim.cnw]) == 0

    @test !haskey(mim.data, "nw"); @test length(mim.data) == 7
    @test haskey(mim.sol, :nw); @test length(mim.ref[:nw][mim.cnw]) == 7
end


### Helper functions for working with AbstractInfrastructureModels
ismultinetwork(aim::AbstractInfrastructureModel) = (length(aim.ref[:nw]) > 1)
nw_ids(aim::AbstractInfrastructureModel) = keys(aim.ref[:nw])
nws(aim::AbstractInfrastructureModel) = aim.ref[:nw]


@testset "helper functions - InitializeInfrastructureModel, ids, ref" begin
    mim = InitializeInfrastructureModel(MyInfrastructureModel, generic_network_data, gn_global_keys)
    @test !ismultinetwork(mim)

    @test length(ids(mim, :comp)) == 3

    @test length(ref(mim, :comp)) == 3
    @test length(ref(mim, :comp, 1)) == 4
    @test ref(mim, :comp, 2, "c") == "same"


    mn_data = replicate(generic_network_data, 3, gn_global_keys)

    mim = InitializeInfrastructureModel(MyInfrastructureModel, mn_data, gn_global_keys)
    @test ismultinetwork(mim)

    @test length(ids(mim, 2, :comp)) == 3; @test length(ids(mim, :comp, nw=3)) == 3

    @test length(ref(mim, 2, :comp)) == 3
    @test length(ref(mim, 2, :comp, 1)) == 4
    @test ref(mim, 2, :comp, 2, "c") == "same"

    @test length(ref(mim, :comp, nw=3)) == 3
    @test length(ref(mim, :comp, 1, nw=3)) == 4
    @test ref(mim, :comp, 2, "c", nw=3) == "same"
end


function build_my_model(aim::AbstractInfrastructureModel)
    for nw in nw_ids(aim)
        c = var(aim, nw)[:c] = JuMP.@variable(aim.model,
            [i in ids(aim, nw, :comp)], base_name="$(nw)_c",
            lower_bound = i*2
        )
        sol_component_value(aim, nw, :comp, :c, ids(aim, nw, :comp), c)
        sol_component_fixed(aim, nw, :comp, :d, ids(aim, nw, :comp), 1.23)
    end

    for nw in nw_ids(aim)
        con(aim, nw)[:comp] = Dict()
        for (c,comp) in ref(aim, nw, :comp)
            cstr = JuMP.@constraint(aim.model, var(aim, nw, :c, c) >= c/2)
            con(aim, nw, :comp)[c] = cstr

            sol(aim, nw, :comp, c)[:c_lb] = cstr
        end
    end

    JuMP.@objective(aim.model, Min, sum(
        sum( var(aim, nw, :c, c)^2 for c in ids(aim, nw, :comp))
        for nw in nw_ids(aim))
    )

    aim.sol[:glb] = 4.56
end

function ref_add_core!(refs::Dict)
    for (nw, ref) in refs[:nw]
        ref[:comp] = Dict(x for x in ref[:comp] if (!haskey(x.second, "status") || x.second["status"] != 0))
    end
end


@testset "helper functions - instantiate_model, var, con, sol" begin
    mim = instantiate_model(generic_network_data, MyInfrastructureModel, build_my_model, ref_add_core!, gn_global_keys)
    @test !ismultinetwork(mim)

    @test length(var(mim, :c)) == 2
    @test isa(var(mim, :c, 1), JuMP.VariableRef)

    @test length(con(mim, :comp)) == 2
    @test isa(con(mim, :comp, 1), JuMP.ConstraintRef)


    mn_data = replicate(generic_network_data, 3, gn_global_keys)

    mim = instantiate_model(mn_data, MyInfrastructureModel, build_my_model, ref_add_core!, gn_global_keys)
    @test ismultinetwork(mim)

    @test length(var(mim, 2, :c)) == 2; @test length(var(mim, :c, nw=3)) == 2
    @test isa(var(mim, 2, :c, 1), JuMP.VariableRef); @test isa(var(mim, :c, 1, nw=3), JuMP.VariableRef)

    @test length(con(mim, 2, :comp)) == 2; @test length(con(mim, :comp, nw=3)) == 2
    @test isa(con(mim, 2, :comp, 1), JuMP.ConstraintRef); @test isa(con(mim, :comp, 1, nw=3), JuMP.ConstraintRef)
end


@testset "helper functions - instantiate_model, optimize_model!, sol" begin
    mim = instantiate_model(generic_network_data, MyInfrastructureModel, build_my_model, ref_add_core!, gn_global_keys)
    result = optimize_model!(mim, optimizer=ipopt_solver)
    solution = result["solution"]

    @test solution["glb"] == 4.56

    @test length(solution["comp"]) == 2

    @test isapprox(solution["comp"]["1"]["c"], 2.0)
    @test isapprox(solution["comp"]["1"]["c_lb"], 0.0, atol=1e-5)
    @test solution["comp"]["1"]["d"] == 1.23

    @test isapprox(solution["comp"]["3"]["c"], 6.0)
    @test isapprox(solution["comp"]["3"]["c_lb"], 0.0, atol=1e-5)
    @test solution["comp"]["3"]["d"] == 1.23


    mn_data = replicate(generic_network_data, 3, gn_global_keys)
    mim = instantiate_model(mn_data, MyInfrastructureModel, build_my_model, ref_add_core!, gn_global_keys)
    result = optimize_model!(mim, optimizer=ipopt_solver)
    solution = result["solution"]

    @test solution["glb"] == 4.56
    @test haskey(solution, "nw")

    for (nw, nw_sol) in solution["nw"]
        @test length(nw_sol["comp"]) == 2

        @test isapprox(nw_sol["comp"]["1"]["c"], 2.0)
        @test isapprox(nw_sol["comp"]["1"]["c_lb"], 0.0, atol=1e-5)
        @test nw_sol["comp"]["1"]["d"] == 1.23

        @test isapprox(nw_sol["comp"]["3"]["c"], 6.0)
        @test isapprox(nw_sol["comp"]["3"]["c_lb"], 0.0, atol=1e-5)
        @test nw_sol["comp"]["3"]["d"] == 1.23
    end
end


@testset "build_result structure" begin
    mim = instantiate_model(generic_network_data, MyInfrastructureModel, build_my_model, ref_add_core!, gn_global_keys)
    result = optimize_model!(mim, optimizer=ipopt_solver)

    @test haskey(result, "optimizer")
    @test haskey(result, "termination_status")
    @test haskey(result, "primal_status")
    @test haskey(result, "dual_status")
    @test haskey(result, "objective")
    @test haskey(result, "objective_lb")
    @test haskey(result, "solve_time")
    @test haskey(result, "machine")
    @test haskey(result, "data")
    @test haskey(result, "solution")
    @test !isnan(result["solve_time"])

    @test length(result["solution"]) == 2
    @test length(result["solution"]["comp"]) == 2

    @test result["termination_status"] == MOI.LOCALLY_SOLVED
    @test result["primal_status"] == MOI.FEASIBLE_POINT
    @test result["dual_status"] == MOI.FEASIBLE_POINT
end
