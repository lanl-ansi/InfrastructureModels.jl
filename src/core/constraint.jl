
"""
Given a continuous variable `x` and a binary variable `z`, sets x to 0.0 when
z is 0.  Requires that 0.0 is in the domain of x.
"""
function constraint_bounds_on_off(m::JuMP.Model, x::JuMP.VariableRef, z::JuMP.VariableRef)
    x_lb, x_ub = variable_domain(x)
    @assert (x_lb <= 0 && x_ub >= 0)
    JuMP.@constraint(m, x <= z*x_ub)
    JuMP.@constraint(m, x >= z*x_lb)
end
