using JuMP
using Compat

using Ipopt
using ECOS
using Juniper

ipopt_solver = IpoptSolver(print_level=0)
ecos_solver = ECOSSolver(verbose=0)
juniper_solver = JuniperSolver(ipopt_solver, log_levels=[])

tolerance = 1e-5
replicates = 10

if VERSION > v"0.7.0-"
    using Random
    Random.seed!(0)
end

if VERSION < v"0.7.0-"
    srand(0)
end

@testset "relaxation schemes" begin

    @testset "relaxation_sqr" begin
        for r in 1:replicates
            x_lb, x_ub = 10*rand(2)
            if x_lb > x_ub
                x_lb, x_ub = x_ub, x_lb
            end
            y_lb, y_ub = (x_lb^2, x_ub^2)

            m = Model(solver=ipopt_solver)
            @variable(m, x_lb <= x <= x_ub)
            @variable(m, y_lb <= y <= y_ub)
            @objective(m, Min, y)
            @constraint(m, x^2 == y)
            status = solve(m)

            rm = Model(solver=ipopt_solver)
            @variable(rm, x_lb <= x <= x_ub)
            @variable(rm, y_lb <= y <= y_ub)
            @objective(rm, Min, y)
            InfrastructureModels.relaxation_sqr(rm, x, y)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) <= getobjectivevalue(m) + tolerance)
            @test(rstatus == status)

            setobjectivesense(m, :Max)
            setobjectivesense(rm, :Max)

            status = solve(m)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) >= getobjectivevalue(m) - tolerance)
            @test(rstatus == status)
        end
    end

    @testset "relaxation_product" begin
        for r in 1:replicates
            x_lb, x_ub = 10*rand(2).*[-1,1]
            y_lb, y_ub = 10*rand(2).*[-1,1]

            m = Model(solver=ipopt_solver)
            @variable(m, x_lb <= x <= x_ub)
            @variable(m, y_lb <= y <= y_ub)
            @variable(m, z)
            @objective(m, Min, z)
            @constraint(m, x*y == z)
            status = solve(m)

            rm = Model(solver=ipopt_solver)
            @variable(rm, x_lb <= x <= x_ub)
            @variable(rm, y_lb <= y <= y_ub)
            @variable(rm, z)
            @objective(rm, Min, z)
            InfrastructureModels.relaxation_product(rm, x, y, z)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) <= getobjectivevalue(m) + tolerance)
            @test(rstatus == status)

            setobjectivesense(m, :Max)
            setobjectivesense(rm, :Max)

            status = solve(m)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) >= getobjectivevalue(m) - tolerance)
            @test(rstatus == status)
        end
    end

    @testset "relaxation_trilinear" begin
        for r in 1:replicates
            x_lb, x_ub = 10*rand(2).*[-1,1]
            y_lb, y_ub = 10*rand(2).*[-1,1]
            z_lb, z_ub = 10*rand(2).*[-1,1]

            m = Model(solver=ipopt_solver)
            @variable(m, x_lb <= x <= x_ub)
            @variable(m, y_lb <= y <= y_ub)
            @variable(m, z_lb <= z <= z_ub)
            @variable(m, w)
            @objective(m, Min, w)
            @NLconstraint(m, x*y*z == w)
            status = solve(m)

            rm = Model(solver=ipopt_solver)
            @variable(rm, x_lb <= x <= x_ub)
            @variable(rm, y_lb <= y <= y_ub)
            @variable(rm, z_lb <= z <= z_ub)
            @variable(rm, 0 <= lambda[1:8] <= 1)
            @variable(rm, w)
            @objective(rm, Min, w)
            InfrastructureModels.relaxation_trilinear(rm, x, y, z, w, lambda)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) <= getobjectivevalue(m) + tolerance)
            @test(rstatus == status)

            setobjectivesense(m, :Max)
            setobjectivesense(rm, :Max)

            status = solve(m)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) >= getobjectivevalue(m) - tolerance)
            @test(rstatus == status)
        end
    end

    @testset "relaxation_complex_product" begin
        for r in 1:replicates
            a_lb, a_ub = 0, 10*rand()
            b_lb, b_ub = 0, 10*rand()
            c_lb, c_ub = 10*rand(2).*[-1,1]
            d_lb, d_ub = 10*rand(2).*[-1,1]

            m = Model(solver=ipopt_solver)
            @variable(m, a_lb <= a <= a_ub)
            @variable(m, b_lb <= b <= b_ub)
            @variable(m, c_lb <= c <= c_ub)
            @variable(m, d_lb <= d <= d_ub)
            @objective(m, Min, a + b)
            @NLconstraint(m, c^2 + d^2 == a*b)
            status = solve(m)

            rm = Model(solver=ipopt_solver)
            @variable(rm, a_lb <= a <= a_ub)
            @variable(rm, b_lb <= b <= b_ub)
            @variable(rm, c_lb <= c <= c_ub)
            @variable(rm, d_lb <= d <= d_ub)
            @objective(rm, Min, a + b)
            InfrastructureModels.relaxation_complex_product(rm, a, b, c, d)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) <= getobjectivevalue(m) + tolerance)
            @test(rstatus == status)

            setobjectivesense(m, :Max)
            setobjectivesense(rm, :Max)

            status = solve(m)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) >= getobjectivevalue(m) - tolerance)
            @test(rstatus == status)
        end
    end

    @testset "relaxation_complex_product_conic" begin
        for r in 1:replicates
            a_lb, a_ub = 0, 10*rand()
            b_lb, b_ub = 0, 10*rand()
            c_lb, c_ub = 10*rand(2).*[-1,1]
            d_lb, d_ub = 10*rand(2).*[-1,1]

            m = Model(solver=ipopt_solver)
            @variable(m, a_lb <= a <= a_ub)
            @variable(m, b_lb <= b <= b_ub)
            @variable(m, c_lb <= c <= c_ub)
            @variable(m, d_lb <= d <= d_ub)
            @objective(m, Min, a + b)
            @NLconstraint(m, c^2 + d^2 == a*b)
            status = solve(m)

            rm = Model(solver=ecos_solver)
            @variable(rm, a_lb <= a <= a_ub)
            @variable(rm, b_lb <= b <= b_ub)
            @variable(rm, c_lb <= c <= c_ub)
            @variable(rm, d_lb <= d <= d_ub)
            @objective(rm, Min, a + b)
            InfrastructureModels.relaxation_complex_product_conic(rm, a, b, c, d)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) <= getobjectivevalue(m) + tolerance)
            @test(rstatus == status)

            setobjectivesense(m, :Max)
            setobjectivesense(rm, :Max)

            status = solve(m)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) >= getobjectivevalue(m) - tolerance)
            @test(rstatus == status)
        end
    end

    @testset "relaxation_equality_on_off" begin
        for r in 1:replicates
            x_lb, x_ub = 10*rand(2).*[-1,1]
            y_lb, y_ub = 2.0*x_lb, 2.0*x_ub

            m = Model(solver=juniper_solver)
            @variable(m, x_lb <= x <= x_ub)
            @variable(m, y_lb <= y <= y_ub)
            @variable(m, z, Bin)
            @objective(m, Min, 10000*z + y)
            @NLconstraint(m, z*x == z*y)
            status = solve(m)

            rm = Model(solver=juniper_solver)
            @variable(rm, x_lb <= rx <= x_ub)
            @variable(rm, y_lb <= ry <= y_ub)
            @variable(rm, rz, Bin)
            @NLobjective(rm, Min, 10000*rz + ry)
            InfrastructureModels.relaxation_equality_on_off(rm, rx, ry, rz)
            rstatus = solve(rm)

            @test(isapprox(getvalue(z), 0))
            @test(isapprox(getvalue(rz), 0))

            #@test(isapprox(getvalue(y), y_lb))
            #@test(isapprox(getvalue(ry), y_lb))

            @test(getobjectivevalue(rm) <= getobjectivevalue(m) + tolerance*100)
            @test(rstatus == status)

            setobjectivesense(m, :Max)
            setobjectivesense(rm, :Max)

            status = solve(m)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) >= getobjectivevalue(m) - tolerance*100)
            @test(rstatus == status)

            @test(isapprox(getvalue(z), 1))
            @test(isapprox(getvalue(rz), 1))

            #@test(isapprox(getvalue(y), x_ub))
            #@test(isapprox(getvalue(ry), x_ub))
        end
    end


    @testset "relaxation_product_on_off" begin
        for r in 1:replicates
            x_lb, x_ub = 10*rand(2).*[-1,1]
            y_lb, y_ub = 10*rand(2).*[-1,1]
            m = max(-x_lb, x_ub, -y_lb, y_ub)
            z_lb, z_ub = -m^2, m^2

            m = Model(solver=juniper_solver)
            @variable(m, x_lb <= x <= x_ub)
            @variable(m, y_lb <= y <= y_ub)
            @variable(m, z_lb <= z <= z_ub)
            @variable(m, ind, Bin)
            @objective(m, Min, 10000*ind + z)
            @NLconstraint(m, x*y == ind*z)
            @NLconstraint(m, z_lb*ind <= z)
            @NLconstraint(m, z_ub*ind >= z)
            status = solve(m)

            rm = Model(solver=juniper_solver)
            @variable(rm, x_lb <= rx <= x_ub)
            @variable(rm, y_lb <= ry <= y_ub)
            @variable(rm, z_lb <= rz <= z_ub)
            @variable(rm, rind, Bin)
            @NLobjective(rm, Min, 10000*rind + rz)
            InfrastructureModels.relaxation_product_on_off(rm, rx, ry, rz, rind)
            @NLconstraint(rm, y_lb*rind <= ry)
            @NLconstraint(rm, y_ub*rind >= ry)
            @NLconstraint(rm, x_lb*rind <= rx)
            @NLconstraint(rm, x_ub*rind >= rx)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) <= getobjectivevalue(m) + tolerance*100)
            @test(rstatus == status)

            @test(isapprox(getvalue(ind), 0))
            @test(isapprox(getvalue(rind), 0))

            setobjectivesense(m, :Max)
            setobjectivesense(rm, :Max)

            status = solve(m)
            rstatus = solve(rm)

            @test(getobjectivevalue(rm) >= getobjectivevalue(m) - tolerance*100)
            @test(rstatus == status)

            @test(isapprox(getvalue(ind), 1))
            @test(isapprox(getvalue(rind), 1))
        end
    end
end


