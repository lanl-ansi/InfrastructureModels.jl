"constraint: `c^2 + d^2 <= a*b`"
function relaxation_complex_product(m, a, b, c, d)
    @assert (JuMP.lower_bound(a) >= 0 && JuMP.lower_bound(b) >= 0) || (JuMP.upper_bound(a) <= 0 && JuMP.upper_bound(b) <= 0)
    @constraint(m, c^2 + d^2 <= a*b)
end

"a conic encoding of constraint: `c^2 + d^2 <= a*b`"
function relaxation_complex_product_conic(m, a, b, c, d)
    @assert (JuMP.lower_bound(a) >= 0 && JuMP.lower_bound(b) >= 0) || (JuMP.upper_bound(a) <= 0 && JuMP.upper_bound(b) <= 0)
    @constraint(m, [a, b, c, d] in RotatedSecondOrderCone())
end

"""
```
c^2 + d^2 <= a*b*getupperbound(z)
c^2 + d^2 <= getupperbound(a)*b*getupperbound(z)
c^2 + d^2 <= a*getupperbound(b)*z
```
"""
function relaxation_complex_product_on_off(m, a, b, c, d, z)
    @assert JuMP.lower_bound(c) <= 0 && JuMP.upper_bound(c) >= 0
    @assert JuMP.lower_bound(d) <= 0 && JuMP.upper_bound(d) >= 0
    # assume c and d are already linked to z in other constraints
    # and will be forced to 0 when z is 0

    a_ub = JuMP.upper_bound(a)
    b_ub = JuMP.upper_bound(b)
    z_ub = JuMP.upper_bound(z)

    @constraint(m, c^2 + d^2 <= a*b*z_ub)
    @constraint(m, c^2 + d^2 <= a_ub*b*z)
    @constraint(m, c^2 + d^2 <= a*b_ub*z)
end


"`x - getupperbound(x)*(1-z) <= y <= x - getlowerbound(x)*(1-z)`"
function relaxation_equality_on_off(m, x, y, z)
    # assumes 0 is in the domain of y when z is 0

    x_ub = JuMP.upper_bound(x)
    x_lb = JuMP.lower_bound(x)

    @constraint(m, y >= x - x_ub*(1-z))
    @constraint(m, y <= x - x_lb*(1-z))
end


"""
general relaxation of a square term

```
x^2 <= y <= (getupperbound(x)+getlowerbound(x))*x - getupperbound(x)*getlowerbound(x)
```
"""
function relaxation_sqr(m, x, y)
    @constraint(m, y >= x^2)
    @constraint(m, y <= (JuMP.upper_bound(x)+JuMP.lower_bound(x))*x - JuMP.upper_bound(x)*JuMP.lower_bound(x))
end


"""
general relaxation of binlinear term (McCormick)

```
z >= getlowerbound(x)*y + getlowerbound(y)*x - getlowerbound(x)*getlowerbound(y)
z >= getupperbound(x)*y + getupperbound(y)*x - getupperbound(x)*getupperbound(y)
z <= getlowerbound(x)*y + getupperbound(y)*x - getlowerbound(x)*getupperbound(y)
z <= getupperbound(x)*y + getlowerbound(y)*x - getupperbound(x)*getlowerbound(y)
```
"""
function relaxation_product(m, x, y, z)
    x_ub = JuMP.upper_bound(x)
    x_lb = JuMP.lower_bound(x)
    y_ub = JuMP.upper_bound(y)
    y_lb = JuMP.lower_bound(y)

    @constraint(m, z >= x_lb*y + y_lb*x - x_lb*y_lb)
    @constraint(m, z >= x_ub*y + y_ub*x - x_ub*y_ub)
    @constraint(m, z <= x_lb*y + y_ub*x - x_lb*y_ub)
    @constraint(m, z <= x_ub*y + y_lb*x - x_ub*y_lb)
end


"""
On/Off variant of binlinear term (McCormick)
requires that all variables (x,y,z) go to zero with ind
"""
function relaxation_product_on_off(m, x, y, z, ind)
    @assert JuMP.lower_bound(x) <= 0 && JuMP.upper_bound(x) >= 0
    @assert JuMP.lower_bound(y) <= 0 && JuMP.upper_bound(y) >= 0
    @assert JuMP.lower_bound(z) <= 0 && JuMP.upper_bound(z) >= 0

    x_ub = JuMP.upper_bound(x)
    x_lb = JuMP.lower_bound(x)
    y_ub = JuMP.upper_bound(y)
    y_lb = JuMP.lower_bound(y)

    @constraint(m, z >= x_lb*y + y_lb*x - ind*x_lb*y_lb)
    @constraint(m, z >= x_ub*y + y_ub*x - ind*x_ub*y_ub)
    @constraint(m, z <= x_lb*y + y_ub*x - ind*x_lb*y_ub)
    @constraint(m, z <= x_ub*y + y_lb*x - ind*x_ub*y_lb)
end


"""
convex hull relaxation of trilinear term

```
w₁ = getlowerbound(x)*getlowerbound(y)*getlowerbound(z)
w₂ = getlowerbound(x)*getlowerbound(y)*getupperbound(z)
w₃ = getlowerbound(x)*getupperbound(y)*getlowerbound(z)
w₄ = getlowerbound(x)*getupperbound(y)*getupperbound(z)
w₅ = getupperbound(x)*getlowerbound(y)*getlowerbound(z)
w₆ = getupperbound(x)*getlowerbound(y)*getupperbound(z)
w₇ = getupperbound(x)*getupperbound(y)*getlowerbound(z)
w₈ = getupperbound(x)*getupperbound(y)*getupperbound(z)
w = λ₁*w₁ + λ₂*w₂ + λ₃*w₃ + λ₄*w₄ + λ₅*w₅ + λ₆*w₆ + λ₇*w₇ + λ₈*w₈
x = (λ₁ + λ₂ + λ₃ + λ₄)*getlowerbound(x) + (λ₅ + λ₆ + λ₇ + λ₈)*getupperbound(x)
y = (λ₁ + λ₂ + λ₅ + λ₆)*getlowerbound(x) + (λ₃ + λ₄ + λ₇ + λ₈)*getupperbound(x)
z = (λ₁ + λ₃ + λ₅ + λ₇)*getlowerbound(x) + (λ₂ + λ₄ + λ₆ + λ₈)*getupperbound(x)
λ₁ + λ₂ + λ₃ + λ₄ + λ₅ + λ₆ + λ₇ + λ₈ = 1
```
"""
function relaxation_trilinear(m, x, y, z, w, lambda)
    x_ub = JuMP.upper_bound(x)
    x_lb = JuMP.lower_bound(x)
    y_ub = JuMP.upper_bound(y)
    y_lb = JuMP.lower_bound(y)
    z_ub = JuMP.upper_bound(z)
    z_lb = JuMP.lower_bound(z)

    @assert length(JuMP.axes(lambda)) == 1
    @assert length.(JuMP.axes(lambda))[1] == 8

    w_val = [x_lb * y_lb * z_lb
             x_lb * y_lb * z_ub
             x_lb * y_ub * z_lb
             x_lb * y_ub * z_ub
             x_ub * y_lb * z_lb
             x_ub * y_lb * z_ub
             x_ub * y_ub * z_lb
             x_ub * y_ub * z_ub]

    @constraint(m, w == sum(w_val[i]*lambda[i] for i in 1:8))
    @constraint(m, x == (lambda[1] + lambda[2] + lambda[3] + lambda[4])*x_lb +
                        (lambda[5] + lambda[6] + lambda[7] + lambda[8])*x_ub)
    @constraint(m, y == (lambda[1] + lambda[2] + lambda[5] + lambda[6])*y_lb +
                        (lambda[3] + lambda[4] + lambda[7] + lambda[8])*y_ub)
    @constraint(m, z == (lambda[1] + lambda[3] + lambda[5] + lambda[7])*z_lb +
                        (lambda[2] + lambda[4] + lambda[6] + lambda[8])*z_ub)
    @constraint(m, sum(lambda) == 1)
end
