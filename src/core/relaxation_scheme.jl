"constraint: `c^2 + d^2 <= a*b`"
function relaxation_complex_product(m, a, b, c, d)
    @assert (JuMP.getlowerbound(a) >= 0 && JuMP.getlowerbound(b) >= 0) || (JuMP.getupperbound(a) <= 0 && JuMP.getupperbound(b) <= 0)
    JuMP.@constraint(m, c^2 + d^2 <= a*b)
end

"a conic encoding of constraint: `c^2 + d^2 <= a*b`"
function relaxation_complex_product_conic(m, a, b, c, d)
    @assert (JuMP.getlowerbound(a) >= 0 && JuMP.getlowerbound(b) >= 0) || (JuMP.getupperbound(a) <= 0 && JuMP.getupperbound(b) <= 0)
    JuMP.@constraint(m, JuMP.norm([(a - b); 2.0*c; 2.0*d]) <= (a + b))
end

"""
```
c^2 + d^2 <= a*b*JuMP.getupperbound(z)
c^2 + d^2 <= JuMP.getupperbound(a)*b*JuMP.getupperbound(z)
c^2 + d^2 <= a*JuMP.getupperbound(b)*z
```
"""
function relaxation_complex_product_on_off(m, a, b, c, d, z)
    @assert JuMP.getlowerbound(c) <= 0 && JuMP.getupperbound(c) >= 0
    @assert JuMP.getlowerbound(d) <= 0 && JuMP.getupperbound(d) >= 0
    # assume c and d are already linked to z in other constraints
    # and will be forced to 0 when z is 0

    a_ub = JuMP.getupperbound(a)
    b_ub = JuMP.getupperbound(b)
    z_ub = JuMP.getupperbound(z)

    JuMP.@constraint(m, c^2 + d^2 <= a*b*z_ub)
    JuMP.@constraint(m, c^2 + d^2 <= a_ub*b*z)
    JuMP.@constraint(m, c^2 + d^2 <= a*b_ub*z)
end


"`x - JuMP.getupperbound(x)*(1-z) <= y <= x - JuMP.getlowerbound(x)*(1-z)`"
function relaxation_equality_on_off(m, x, y, z)
    # assumes 0 is in the domain of y when z is 0

    x_ub = JuMP.getupperbound(x)
    x_lb = JuMP.getlowerbound(x)

    JuMP.@constraint(m, y >= x - x_ub*(1-z))
    JuMP.@constraint(m, y <= x - x_lb*(1-z))
end


"""
general relaxation of a square term

```
x^2 <= y <= (JuMP.getupperbound(x)+JuMP.getlowerbound(x))*x - JuMP.getupperbound(x)*JuMP.getlowerbound(x)
```
"""
function relaxation_sqr(m, x, y)
    JuMP.@constraint(m, y >= x^2)
    JuMP.@constraint(m, y <= (JuMP.getupperbound(x)+JuMP.getlowerbound(x))*x - JuMP.getupperbound(x)*JuMP.getlowerbound(x))
end


"""
general relaxation of binlinear term (McCormick)

```
z >= JuMP.getlowerbound(x)*y + JuMP.getlowerbound(y)*x - JuMP.getlowerbound(x)*JuMP.getlowerbound(y)
z >= JuMP.getupperbound(x)*y + JuMP.getupperbound(y)*x - JuMP.getupperbound(x)*JuMP.getupperbound(y)
z <= JuMP.getlowerbound(x)*y + JuMP.getupperbound(y)*x - JuMP.getlowerbound(x)*JuMP.getupperbound(y)
z <= JuMP.getupperbound(x)*y + JuMP.getlowerbound(y)*x - JuMP.getupperbound(x)*JuMP.getlowerbound(y)
```
"""
function relaxation_product(m, x, y, z)
    x_ub = JuMP.getupperbound(x)
    x_lb = JuMP.getlowerbound(x)
    y_ub = JuMP.getupperbound(y)
    y_lb = JuMP.getlowerbound(y)

    JuMP.@constraint(m, z >= x_lb*y + y_lb*x - x_lb*y_lb)
    JuMP.@constraint(m, z >= x_ub*y + y_ub*x - x_ub*y_ub)
    JuMP.@constraint(m, z <= x_lb*y + y_ub*x - x_lb*y_ub)
    JuMP.@constraint(m, z <= x_ub*y + y_lb*x - x_ub*y_lb)
end


"""
On/Off variant of binlinear term (McCormick)
requires that all variables (x,y,z) go to zero with ind
"""
function relaxation_product_on_off(m, x, y, z, ind)
    @assert JuMP.getlowerbound(x) <= 0 && JuMP.getupperbound(x) >= 0
    @assert JuMP.getlowerbound(y) <= 0 && JuMP.getupperbound(y) >= 0
    @assert JuMP.getlowerbound(z) <= 0 && JuMP.getupperbound(z) >= 0

    x_ub = JuMP.getupperbound(x)
    x_lb = JuMP.getlowerbound(x)
    y_ub = JuMP.getupperbound(y)
    y_lb = JuMP.getlowerbound(y)

    JuMP.@constraint(m, z >= x_lb*y + y_lb*x - ind*x_lb*y_lb)
    JuMP.@constraint(m, z >= x_ub*y + y_ub*x - ind*x_ub*y_ub)
    JuMP.@constraint(m, z <= x_lb*y + y_ub*x - ind*x_lb*y_ub)
    JuMP.@constraint(m, z <= x_ub*y + y_lb*x - ind*x_ub*y_lb)
end


"""
convex hull relaxation of trilinear term

```
w₁ = JuMP.getlowerbound(x)*JuMP.getlowerbound(y)*JuMP.getlowerbound(z)
w₂ = JuMP.getlowerbound(x)*JuMP.getlowerbound(y)*JuMP.getupperbound(z)
w₃ = JuMP.getlowerbound(x)*JuMP.getupperbound(y)*JuMP.getlowerbound(z)
w₄ = JuMP.getlowerbound(x)*JuMP.getupperbound(y)*JuMP.getupperbound(z)
w₅ = JuMP.getupperbound(x)*JuMP.getlowerbound(y)*JuMP.getlowerbound(z)
w₆ = JuMP.getupperbound(x)*JuMP.getlowerbound(y)*JuMP.getupperbound(z)
w₇ = JuMP.getupperbound(x)*JuMP.getupperbound(y)*JuMP.getlowerbound(z)
w₈ = JuMP.getupperbound(x)*JuMP.getupperbound(y)*JuMP.getupperbound(z)
w = λ₁*w₁ + λ₂*w₂ + λ₃*w₃ + λ₄*w₄ + λ₅*w₅ + λ₆*w₆ + λ₇*w₇ + λ₈*w₈
x = (λ₁ + λ₂ + λ₃ + λ₄)*JuMP.getlowerbound(x) + (λ₅ + λ₆ + λ₇ + λ₈)*JuMP.getupperbound(x)
y = (λ₁ + λ₂ + λ₅ + λ₆)*JuMP.getlowerbound(x) + (λ₃ + λ₄ + λ₇ + λ₈)*JuMP.getupperbound(x)
z = (λ₁ + λ₃ + λ₅ + λ₇)*JuMP.getlowerbound(x) + (λ₂ + λ₄ + λ₆ + λ₈)*JuMP.getupperbound(x)
λ₁ + λ₂ + λ₃ + λ₄ + λ₅ + λ₆ + λ₇ + λ₈ = 1
```
"""
function relaxation_trilinear(m, x, y, z, w, lambda)
    x_ub = JuMP.getupperbound(x)
    x_lb = JuMP.getlowerbound(x)
    y_ub = JuMP.getupperbound(y)
    y_lb = JuMP.getlowerbound(y)
    z_ub = JuMP.getupperbound(z)
    z_lb = JuMP.getlowerbound(z)


    @assert length(lambda) == 8

    w_val = [x_lb * y_lb * z_lb
             x_lb * y_lb * z_ub
             x_lb * y_ub * z_lb
             x_lb * y_ub * z_ub
             x_ub * y_lb * z_lb
             x_ub * y_lb * z_ub
             x_ub * y_ub * z_lb
             x_ub * y_ub * z_ub]

    JuMP.@constraint(m, w == sum(w_val[i]*lambda[i] for i in 1:8))
    JuMP.@constraint(m, x == (lambda[1] + lambda[2] + lambda[3] + lambda[4])*x_lb +
                        (lambda[5] + lambda[6] + lambda[7] + lambda[8])*x_ub)
    JuMP.@constraint(m, y == (lambda[1] + lambda[2] + lambda[5] + lambda[6])*y_lb +
                        (lambda[3] + lambda[4] + lambda[7] + lambda[8])*y_ub)
    JuMP.@constraint(m, z == (lambda[1] + lambda[3] + lambda[5] + lambda[7])*z_lb +
                        (lambda[2] + lambda[4] + lambda[6] + lambda[8])*z_ub)
    JuMP.@constraint(m, sum(lambda) == 1)
end
