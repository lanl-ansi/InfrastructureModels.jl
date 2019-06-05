
tolerance = 1e-5
replicates = 10

seed!(0)

@testset "relaxation schemes" begin

    @testset "relaxation_sqr" begin
        for r in 1:replicates
            x_lb, x_ub = 10*rand(2)
            if x_lb > x_ub
                x_lb, x_ub = x_ub, x_lb
            end
            y_lb, y_ub = (x_lb^2, x_ub^2)

            m = JuMP.Model(ipopt_solver)
            JuMP.@variable(m, x_lb <= x <= x_ub)
            JuMP.@variable(m, y_lb <= y <= y_ub)
            JuMP.@objective(m, Min, y)
            JuMP.@constraint(m, x^2 == y)
            status = JuMP.optimize!(m)

            rm = JuMP.Model(ipopt_solver)
            JuMP.@variable(rm, x_lb <= x <= x_ub)
            JuMP.@variable(rm, y_lb <= y <= y_ub)
            JuMP.@objective(rm, Min, y)
            InfrastructureModels.relaxation_sqr(rm, x, y)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) <= JuMP.objective_value(m) + tolerance)
            @test(rstatus == status)

            JuMP.set_objective_sense(m, MOI.MAX_SENSE)
            JuMP.set_objective_sense(rm, MOI.MAX_SENSE)

            status = JuMP.optimize!(m)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) >= JuMP.objective_value(m) - tolerance)
            @test(rstatus == status)
        end
    end

    @testset "relaxation_product" begin
        for r in 1:replicates
            x_lb, x_ub = 10*rand(2).*[-1,1]
            y_lb, y_ub = 10*rand(2).*[-1,1]

            m = JuMP.Model(ipopt_solver)
            JuMP.@variable(m, x_lb <= x <= x_ub)
            JuMP.@variable(m, y_lb <= y <= y_ub)
            JuMP.@variable(m, z)
            JuMP.@objective(m, Min, z)
            JuMP.@constraint(m, x*y == z)
            status = JuMP.optimize!(m)

            rm = JuMP.Model(ipopt_solver)
            JuMP.@variable(rm, x_lb <= x <= x_ub)
            JuMP.@variable(rm, y_lb <= y <= y_ub)
            JuMP.@variable(rm, z)
            JuMP.@objective(rm, Min, z)
            InfrastructureModels.relaxation_product(rm, x, y, z)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) <= JuMP.objective_value(m) + tolerance)
            @test(rstatus == status)

            JuMP.set_objective_sense(m, MOI.MAX_SENSE)
            JuMP.set_objective_sense(rm, MOI.MAX_SENSE)

            status = JuMP.optimize!(m)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) >= JuMP.objective_value(m) - tolerance)
            @test(rstatus == status)
        end
    end

    @testset "relaxation_trilinear" begin
        for r in 1:replicates
            x_lb, x_ub = 10*rand(2).*[-1,1]
            y_lb, y_ub = 10*rand(2).*[-1,1]
            z_lb, z_ub = 10*rand(2).*[-1,1]

            m = JuMP.Model(ipopt_solver)
            JuMP.@variable(m, x_lb <= x <= x_ub)
            JuMP.@variable(m, y_lb <= y <= y_ub)
            JuMP.@variable(m, z_lb <= z <= z_ub)
            JuMP.@variable(m, w)
            JuMP.@objective(m, Min, w)
            JuMP.@NLconstraint(m, x*y*z == w)
            status = JuMP.optimize!(m)

            rm = JuMP.Model(ipopt_solver)
            JuMP.@variable(rm, x_lb <= x <= x_ub)
            JuMP.@variable(rm, y_lb <= y <= y_ub)
            JuMP.@variable(rm, z_lb <= z <= z_ub)
            JuMP.@variable(rm, 0 <= lambda[1:8] <= 1)
            JuMP.@variable(rm, w)
            JuMP.@objective(rm, Min, w)
            InfrastructureModels.relaxation_trilinear(rm, x, y, z, w, lambda)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) <= JuMP.objective_value(m) + tolerance)
            @test(rstatus == status)

            JuMP.set_objective_sense(m, MOI.MAX_SENSE)
            JuMP.set_objective_sense(rm, MOI.MAX_SENSE)

            status = JuMP.optimize!(m)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) >= JuMP.objective_value(m) - tolerance)
            @test(rstatus == status)
        end
    end

    @testset "relaxation_complex_product" begin
        for r in 1:replicates
            a_lb, a_ub = 0, 10*rand()
            b_lb, b_ub = 0, 10*rand()
            c_lb, c_ub = 10*rand(2).*[-1,1]
            d_lb, d_ub = 10*rand(2).*[-1,1]

            m = JuMP.Model(ipopt_solver)
            JuMP.@variable(m, a_lb <= a <= a_ub)
            JuMP.@variable(m, b_lb <= b <= b_ub)
            JuMP.@variable(m, c_lb <= c <= c_ub)
            JuMP.@variable(m, d_lb <= d <= d_ub)
            JuMP.@objective(m, Min, a + b)
            JuMP.@NLconstraint(m, c^2 + d^2 == a*b)
            status = JuMP.optimize!(m)

            rm = JuMP.Model(ipopt_solver)
            JuMP.@variable(rm, a_lb <= a <= a_ub)
            JuMP.@variable(rm, b_lb <= b <= b_ub)
            JuMP.@variable(rm, c_lb <= c <= c_ub)
            JuMP.@variable(rm, d_lb <= d <= d_ub)
            JuMP.@objective(rm, Min, a + b)
            InfrastructureModels.relaxation_complex_product(rm, a, b, c, d)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) <= JuMP.objective_value(m) + tolerance)
            @test(rstatus == status)

            JuMP.set_objective_sense(m, MOI.MAX_SENSE)
            JuMP.set_objective_sense(rm, MOI.MAX_SENSE)

            status = JuMP.optimize!(m)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) >= JuMP.objective_value(m) - tolerance)
            @test(rstatus == status)
        end
    end

    @testset "relaxation_complex_product_conic" begin
        for r in 1:replicates
            a_lb, a_ub = 0, 10*rand()
            b_lb, b_ub = 0, 10*rand()
            c_lb, c_ub = 10*rand(2).*[-1,1]
            d_lb, d_ub = 10*rand(2).*[-1,1]

            m = JuMP.Model(ipopt_solver)
            JuMP.@variable(m, a_lb <= a <= a_ub)
            JuMP.@variable(m, b_lb <= b <= b_ub)
            JuMP.@variable(m, c_lb <= c <= c_ub)
            JuMP.@variable(m, d_lb <= d <= d_ub)
            JuMP.@objective(m, Min, a + b)
            JuMP.@NLconstraint(m, c^2 + d^2 == a*b)
            status = JuMP.optimize!(m)

            rm = JuMP.Model(ecos_solver)
            JuMP.@variable(rm, a_lb <= a <= a_ub)
            JuMP.@variable(rm, b_lb <= b <= b_ub)
            JuMP.@variable(rm, c_lb <= c <= c_ub)
            JuMP.@variable(rm, d_lb <= d <= d_ub)
            JuMP.@objective(rm, Min, a + b)
            InfrastructureModels.relaxation_complex_product_conic(rm, a, b, c, d)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) <= JuMP.objective_value(m) + tolerance)
            @test(rstatus == status)

            JuMP.set_objective_sense(m, MOI.MAX_SENSE)
            JuMP.set_objective_sense(rm, MOI.MAX_SENSE)

            status = JuMP.optimize!(m)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) >= JuMP.objective_value(m) - tolerance)
            @test(rstatus == status)
        end
    end

    @testset "relaxation_equality_on_off" begin
        for r in 1:replicates
            x_lb, x_ub = 10*rand(2).*[-1,1]
            y_lb, y_ub = 2.0*x_lb, 2.0*x_ub

            m = JuMP.Model(juniper_solver)
            JuMP.@variable(m, x_lb <= x <= x_ub)
            JuMP.@variable(m, y_lb <= y <= y_ub)
            JuMP.@variable(m, z, binary=true)
            JuMP.@objective(m, Min, 10000*z + y)
            JuMP.@NLconstraint(m, z*x == z*y)
            status = JuMP.optimize!(m)

            rm = JuMP.Model(juniper_solver)
            JuMP.@variable(rm, x_lb <= rx <= x_ub)
            JuMP.@variable(rm, y_lb <= ry <= y_ub)
            JuMP.@variable(rm, rz, binary=true)
            JuMP.@NLobjective(rm, Min, 10000*rz + ry)
            InfrastructureModels.relaxation_equality_on_off(rm, rx, ry, rz)
            rstatus = JuMP.optimize!(rm)

            @test(isapprox(JuMP.getvalue(z), 0))
            @test(isapprox(JuMP.getvalue(rz), 0))

            #@test(isapprox(JuMP.getvalue(y), y_lb))
            #@test(isapprox(JuMP.getvalue(ry), y_lb))

            @test(JuMP.objective_value(rm) <= JuMP.objective_value(m) + tolerance*100)
            @test(rstatus == status)

            JuMP.set_objective_sense(m, MOI.MAX_SENSE)
            JuMP.set_objective_sense(rm, MOI.MAX_SENSE)

            status = JuMP.optimize!(m)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) >= JuMP.objective_value(m) - tolerance*100)
            @test(rstatus == status)

            @test(isapprox(JuMP.getvalue(z), 1))
            @test(isapprox(JuMP.getvalue(rz), 1))

            #@test(isapprox(JuMP.getvalue(y), x_ub))
            #@test(isapprox(JuMP.getvalue(ry), x_ub))
        end
    end


    @testset "relaxation_product_on_off" begin
        for r in 1:replicates
            x_lb, x_ub = 10*rand(2).*[-1,1]
            y_lb, y_ub = 10*rand(2).*[-1,1]
            m = max(-x_lb, x_ub, -y_lb, y_ub)
            z_lb, z_ub = -m^2, m^2

            m = JuMP.Model(juniper_solver)
            JuMP.@variable(m, x_lb <= x <= x_ub)
            JuMP.@variable(m, y_lb <= y <= y_ub)
            JuMP.@variable(m, z_lb <= z <= z_ub)
            JuMP.@variable(m, ind, binary=true)
            JuMP.@objective(m, Min, 10000*ind + z)
            JuMP.@NLconstraint(m, x*y == ind*z)
            JuMP.@NLconstraint(m, z_lb*ind <= z)
            JuMP.@NLconstraint(m, z_ub*ind >= z)
            status = JuMP.optimize!(m)

            rm = JuMP.Model(juniper_solver)
            JuMP.@variable(rm, x_lb <= rx <= x_ub)
            JuMP.@variable(rm, y_lb <= ry <= y_ub)
            JuMP.@variable(rm, z_lb <= rz <= z_ub)
            JuMP.@variable(rm, rind, binary=true)
            JuMP.@NLobjective(rm, Min, 10000*rind + rz)
            InfrastructureModels.relaxation_product_on_off(rm, rx, ry, rz, rind)
            JuMP.@NLconstraint(rm, y_lb*rind <= ry)
            JuMP.@NLconstraint(rm, y_ub*rind >= ry)
            JuMP.@NLconstraint(rm, x_lb*rind <= rx)
            JuMP.@NLconstraint(rm, x_ub*rind >= rx)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) <= JuMP.objective_value(m) + tolerance*100)
            @test(rstatus == status)

            @test(isapprox(JuMP.getvalue(ind), 0))
            @test(isapprox(JuMP.getvalue(rind), 0))

            JuMP.set_objective_sense(m, MOI.MAX_SENSE)
            JuMP.set_objective_sense(rm, MOI.MAX_SENSE)

            status = JuMP.optimize!(m)
            rstatus = JuMP.optimize!(rm)

            @test(JuMP.objective_value(rm) >= JuMP.objective_value(m) - tolerance*100)
            @test(rstatus == status)

            @test(isapprox(JuMP.getvalue(ind), 1))
            @test(isapprox(JuMP.getvalue(rind), 1))
        end
    end
end


