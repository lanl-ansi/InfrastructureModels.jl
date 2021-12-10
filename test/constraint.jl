replicates = 10

seed!(0)

@testset "constraints" begin
    @testset "bounds on/off" begin
        x_lb, x_ub = 10*rand(2)
        x_lb = -x_lb

        m = JuMP.Model(juniper_solver)
        JuMP.@variable(m, x_lb <= x <= x_ub)
        JuMP.@variable(m, z, binary=true)
        JuMP.@objective(m, Min, 10000*z + x)
        InfrastructureModels.constraint_bounds_on_off(m, x, z)
        status = JuMP.optimize!(m)

        @test(isapprox(JuMP.value(x), 0.0, atol=1e-8))
        @test(isapprox(JuMP.value(z), 0.0, atol=1e-8))


        m = JuMP.Model(juniper_solver)
        JuMP.@variable(m, x_lb <= x <= x_ub)
        JuMP.@variable(m, z, binary=true)
        JuMP.@objective(m, Min, x)
        InfrastructureModels.constraint_bounds_on_off(m, x, z)
        status = JuMP.optimize!(m)

        @test(isapprox(JuMP.value(x), x_lb))
        @test(isapprox(JuMP.value(z), 1.0))
    end
end
