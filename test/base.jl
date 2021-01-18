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
    ref = ref_initialize(generic_mi_network_data)

    @test !haskey(ref, :dict)
    @test !haskey(ref, :per_unit)

    @test ref[:it][:foo][:nw][0][:a] == 1
    @test ref[:it][:foo][:nw][0][:b] == "bloop"
    @test ref[:it][:foo][:nw][0][:per_unit] == false
    @test ref[:it][:foo][:nw][0][:dict]["b"] == 2.0
    @test ref[:it][:foo][:nw][0][:comp][2]["a"] == 3
end

@testset "ref initialize with global keys" begin
    ref = ref_initialize(generic_si_network_data, "foo", Set(["per_unit", "dict"]))

    @test ref[:it][:foo][:per_unit] == false
    @test ref[:it][:foo][:dict]["b"] == 2.0

    @test !haskey(ref[:it][:foo][:nw][0], :dict)
    @test !haskey(ref[:it][:foo][:nw][0], :per_unit)
    @test ref[:it][:foo][:nw][0][:a] == 1
    @test ref[:it][:foo][:nw][0][:b] == "bloop"
    @test ref[:it][:foo][:nw][0][:comp][2]["a"] == 3
end


abstract type MyAbstractInfrastructureModel <: AbstractInfrastructureModel end
mutable struct MyInfrastructureModel <: MyAbstractInfrastructureModel @im_fields end

@testset "@im_fields and InitializeInfrastructureModel" begin
    global_keys = Set{String}()
    mim = InitializeInfrastructureModel(MyInfrastructureModel, generic_mi_network_data, global_keys)
    mim_clone = InitializeInfrastructureModel(MyInfrastructureModel, generic_mi_network_data, global_keys, :foo)

    @test mim.data == mim_clone.data
    @test mim.ref == mim_clone.ref

    @test isa(mim.model, JuMP.AbstractModel)

    @test length(mim.data["it"]["foo"]) == 6
    @test length(mim.setting) == 0
    @test length(mim.solution) == 0
    @test length(mim.ext) == 0

    @test mim.cnw == 0

    @test haskey(mim.ref[:it][:foo], :nw); @test length(mim.ref[:it][:foo][:nw][mim.cnw]) == 6
    @test haskey(mim.var[:it][:foo], :nw); @test length(mim.var[:it][:foo][:nw][mim.cnw]) == 0
    @test haskey(mim.con[:it][:foo], :nw); @test length(mim.con[:it][:foo][:nw][mim.cnw]) == 0
    @test haskey(mim.sol[:it][:foo], :nw); @test length(mim.sol[:it][:foo][:nw][mim.cnw]) == 0

    @test haskey(mim.sol_proc[:it][:foo], :nw); @test length(mim.sol_proc[:it][:foo][:nw][mim.cnw]) == 0

    @test !haskey(mim.data["it"]["foo"], "nw"); @test length(mim.data["it"]["foo"]) == 6
    @test haskey(mim.sol[:it][:foo], :nw); @test length(mim.ref[:it][:foo][:nw][mim.cnw]) == 6
end


@testset "helper functions - InitializeInfrastructureModel, ids, ref" begin
    mim = InitializeInfrastructureModel(MyInfrastructureModel, generic_si_network_data, gn_global_keys, :foo)

    @test !ismultinetwork(mim, :foo)

    @test length(ids(mim, :foo, :comp)) == 3
    @test length(ref(mim, :foo, :comp)) == 3
    @test length(ref(mim, :foo, :comp, 1)) == 4
    @test ref(mim, :foo, :comp, 2, "c") == "same"

    mn_data = replicate(generic_si_network_data, 3, gn_global_keys)
    mn_data = Dict{String, Any}("it" => Dict{String, Any}("foo" => mn_data))
    mn_data["multiinfrastructure"] = true # Set the multiinfrastructure flag.

    mim = InitializeInfrastructureModel(MyInfrastructureModel, mn_data, gn_global_keys)
    @test ismultinetwork(mim, :foo)

    @test length(ids(mim, :foo, 2, :comp)) == 3
    @test length(ids(mim, :foo, :comp, nw = 3)) == 3

    @test length(ref(mim, :foo, 2, :comp)) == 3
    @test length(ref(mim, :foo, 2, :comp, 1)) == 4
    @test ref(mim, :foo, 2, :comp, 2, "c") == "same"

    @test length(ref(mim, :foo, :comp, nw = 3)) == 3
    @test length(ref(mim, :foo, :comp, 1, nw = 3)) == 4
    @test ref(mim, :foo, :comp, 2, "c", nw = 3) == "same"
end


function build_my_model(aim::MyAbstractInfrastructureModel)
    for nw in nw_ids(aim, :foo)
        c = var(aim, :foo, nw)[:c] = JuMP.@variable(aim.model,
            [i in ids(aim, :foo, nw, :comp)], base_name="$(nw)_c",
            lower_bound = i*2
        )

        sol_component_value(aim, :foo, nw, :comp, :c, ids(aim, :foo, nw, :comp), c)
        sol_component_fixed(aim, :foo, nw, :comp, :d, ids(aim, :foo, nw, :comp), 1.23)
    end

    for nw in nw_ids(aim, :foo)
        con(aim, :foo, nw)[:comp] = Dict()
        for (c, comp) in ref(aim, :foo, nw, :comp)
            cstr = JuMP.@constraint(aim.model, var(aim, :foo, nw, :c, c) >= 0.5 * c)
            con(aim, :foo, nw, :comp)[c] = cstr
            sol(aim, :foo, nw, :comp, c)[:c_lb] = cstr
        end
    end

    JuMP.@objective(aim.model, Min, sum(
        sum( var(aim, :foo, nw, :c, c)^2 for c in ids(aim, :foo, nw, :comp))
        for nw in nw_ids(aim, :foo))
    )

    aim.sol[:it][:foo][:glb] = 4.56
end


function ref_add_core!(ref::Dict)
    apply!(_ref_add_core!, ref, :foo)
end


function _ref_add_core!(ref::Dict)
    ref[:comp] = Dict(x for x in ref[:comp] if (!haskey(x.second, "status") || x.second["status"] != 0))
end


function ref_ext_comp_stat!(ref::Dict, data::Dict)
    apply!(_ref_ext_comp_stat!, ref, data, :foo)
end

function _ref_ext_comp_stat!(ref::Dict, data::Dict)
    ref[:comp_with_status] = Set([parse(Int, i) for (i, comp) in data["comp"] if haskey(comp, "status")])
end

""
function InfrastructureModels.solution_preprocessor(aim::MyAbstractInfrastructureModel, solution::Dict)
    data_it = ismultiinfrastructure(aim.data) ? aim.data["it"]["foo"] : aim.data
    solution["it"]["foo"]["per_unit"] = data_it["per_unit"]

    for (nw_id, nw_ref) in nws(aim, :foo)
        solution["it"]["foo"]["nw"]["$(nw_id)"]["b"] = nw_ref[:b]
    end
end


@testset "external build_ref" begin
    # Case where data is not in a multi-infrastructure format.
    ref = build_ref(generic_si_network_data, ref_add_core!, gn_global_keys, "foo"; ref_extensions=[ref_ext_comp_stat!])

    @test length(ref[:it][:foo][:nw][0][:comp]) == 2
    @test length(ref[:it][:foo][:nw][0][:comp][1]) == 4
    @test ref[:it][:foo][:nw][0][:comp][1]["c"] == "same"

    @test length(ref[:it][:foo][:nw][0][:comp_with_status]) == 2

    # Case where data is in a multi-infrastructure format.
    ref = build_ref(generic_mi_network_data, ref_add_core!, gn_global_keys; ref_extensions=[ref_ext_comp_stat!])

    @test length(ref[:it][:foo][:nw][0][:comp]) == 2
    @test length(ref[:it][:foo][:nw][0][:comp][1]) == 4
    @test ref[:it][:foo][:nw][0][:comp][1]["c"] == "same"

    @test length(ref[:it][:foo][:nw][0][:comp_with_status]) == 2
end


@testset "helper functions - instantiate_model, ref_extensions, var, con, sol" begin
    mim = instantiate_model(
        generic_mi_network_data, MyInfrastructureModel, build_my_model, ref_add_core!,
        gn_global_keys; it = :foo, ref_extensions = [ref_ext_comp_stat!])

    @test !ismultinetwork(mim, :foo)
    @test ismultinetwork(mim, :foo) == ismultinetwork(mim.data["it"]["foo"])

    @test length(var(mim, :foo, :c)) == 2
    @test isa(var(mim, :foo, :c, 1), JuMP.VariableRef)

    @test length(con(mim, :foo, :comp)) == 2
    @test isa(con(mim, :foo, :comp, 1), JuMP.ConstraintRef)

    @test length(ref(mim, :foo, :comp_with_status)) == 2

    mn_data = replicate(generic_mi_network_data["it"]["foo"], 1, gn_global_keys)
    mn_data = Dict{String, Any}("it" => Dict{String, Any}("foo" => mn_data))
    mn_data["multiinfrastructure"] = true

    mim = instantiate_model(
        mn_data, MyInfrastructureModel, build_my_model, ref_add_core!, gn_global_keys;
        it = :foo, ref_extensions = [ref_ext_comp_stat!])

    @test ismultinetwork(mim, :foo)
    @test ismultinetwork(mim, :foo) == ismultinetwork(mim.data["it"]["foo"])

    @test length(var(mim, :foo, 1, :c)) == 2
    @test length(var(mim, :foo, :c, nw = 1)) == 2
    @test isa(var(mim, :foo, 1, :c, 1), JuMP.VariableRef)
    @test isa(var(mim, :foo, :c, 1, nw = 1), JuMP.VariableRef)

    @test length(con(mim, :foo, 1, :comp)) == 2
    @test length(con(mim, :foo, :comp, nw = 1)) == 2
    @test isa(con(mim, :foo, 1, :comp, 1), JuMP.ConstraintRef)
    @test isa(con(mim, :foo, :comp, 1, nw = 1), JuMP.ConstraintRef)
    @test length(ref(mim, :foo, 1, :comp_with_status)) == 2
    @test length(ref(mim, :foo, :comp_with_status, nw = 1)) == 2

    mn_data = replicate(generic_mi_network_data["it"]["foo"], 3, gn_global_keys)
    mn_data = Dict{String, Any}("it" => Dict{String, Any}("foo" => mn_data))
    mn_data["multiinfrastructure"] = true

    mim = instantiate_model(
        mn_data, MyInfrastructureModel, build_my_model, ref_add_core!, gn_global_keys;
        it = :foo, ref_extensions=[ref_ext_comp_stat!])

    @test ismultinetwork(mim, :foo)
    @test ismultinetwork(mim, :foo) == ismultinetwork(mim.data["it"]["foo"])

    @test length(var(mim, :foo, 2, :c)) == 2
    @test length(var(mim, :foo, :c, nw = 3)) == 2
    @test isa(var(mim, :foo, 2, :c, 1), JuMP.VariableRef)
    @test isa(var(mim, :foo, :c, 1, nw = 3), JuMP.VariableRef)

    @test length(con(mim, :foo, 2, :comp)) == 2
    @test length(con(mim, :foo, :comp, nw = 3)) == 2
    @test isa(con(mim, :foo, 2, :comp, 1), JuMP.ConstraintRef)
    @test isa(con(mim, :foo, :comp, 1, nw = 3), JuMP.ConstraintRef)
    @test length(ref(mim, :foo, 2, :comp_with_status)) == 2
    @test length(ref(mim, :foo, :comp_with_status, nw = 3)) == 2
end


@testset "helper functions - instantiate_model, optimize_model!, sol" begin
    mim = instantiate_model(
        generic_mi_network_data, MyInfrastructureModel, build_my_model, ref_add_core!,
        gn_global_keys; it = :foo, ref_extensions = [ref_ext_comp_stat!])

    result = optimize_model!(mim, optimizer = ipopt_solver)
    solution = result["solution"]["it"]["foo"]

    @test solution["glb"] == 4.56
    @test haskey(solution, "per_unit")

    @test haskey(solution, "b")
    @test length(solution["comp"]) == 2

    @test isapprox(solution["comp"]["1"]["c"], 2.0)
    @test isapprox(solution["comp"]["1"]["c_lb"], 0.0, atol=1e-5)
    @test solution["comp"]["1"]["d"] == 1.23

    @test isapprox(solution["comp"]["3"]["c"], 6.0)
    @test isapprox(solution["comp"]["3"]["c_lb"], 0.0, atol=1e-5)
    @test solution["comp"]["3"]["d"] == 1.23

    mn_it = replicate(generic_mi_network_data["it"]["foo"], 3, gn_global_keys)
    mn_data = Dict{String, Any}("it" => Dict{String, Any}("foo" => mn_it))
    mn_data["dep"] = replicate(generic_mi_network_data["dep"], 3, gn_global_keys)
    mn_data["multiinfrastructure"] = true

    mim = instantiate_model(
        mn_data, MyInfrastructureModel, build_my_model, ref_add_core!, gn_global_keys;
        it = :foo, ref_extensions = [ref_ext_comp_stat!])

    result = optimize_model!(mim, optimizer = ipopt_solver)
    solution = result["solution"]["it"]["foo"]

    @test solution["glb"] == 4.56
    @test haskey(solution, "per_unit")
    @test haskey(solution, "nw")

    for (nw, nw_sol) in solution["nw"]
        @test haskey(nw_sol, "b")
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
    mim = instantiate_model(
        generic_si_network_data, MyInfrastructureModel, build_my_model, ref_add_core!,
        gn_global_keys; it = :foo, ref_extensions = [ref_ext_comp_stat!])

    result = optimize_model!(mim, optimizer = ipopt_solver)

    @test haskey(result, "optimizer")
    @test haskey(result, "termination_status")
    @test haskey(result, "primal_status")
    @test haskey(result, "dual_status")
    @test haskey(result, "objective")
    @test haskey(result, "objective_lb")
    @test haskey(result, "solve_time")
    @test haskey(result, "solution")
    @test !isnan(result["solve_time"])


    @test length(result["solution"]) == 6
    @test length(result["solution"]["comp"]) == 2

    @test result["termination_status"] == MOI.LOCALLY_SOLVED
    @test result["primal_status"] == MOI.FEASIBLE_POINT
    @test result["dual_status"] == MOI.FEASIBLE_POINT
end
