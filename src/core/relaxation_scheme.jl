"constraint: `c^2 + d^2 <= a*b`"
function relaxation_complex_product(m, a, b, c, d)
    @assert (JuMP.lowerbound(a) >= 0 && JuMP.lowerbound(b) >= 0) || (JuMP.upperbound(a) <= 0 && JuMP.upperbound(b) <= 0)
    @constraint(m, c^2 + d^2 <= a*b)
end


"""
```
c^2 + d^2 <= a*b*JuMP.upperbound(z)
c^2 + d^2 <= JuMP.upperbound(a)*b*JuMP.upperbound(z)
c^2 + d^2 <= a*JuMP.upperbound(b)*z
```
"""
function relaxation_complex_product_on_off(m, a, b, c, d, z)
    @assert JuMP.lowerbound(c) <= 0 && JuMP.upperbound(c) >= 0
    @assert JuMP.lowerbound(d) <= 0 && JuMP.upperbound(d) >= 0
    # assume c and d are already linked to z in other constraints
    # and will be forced to 0 when z is 0

    a_ub = JuMP.upperbound(a)
    b_ub = JuMP.upperbound(b)
    z_ub = JuMP.upperbound(z)

    @constraint(m, c^2 + d^2 <= a*b*z_ub)
    @constraint(m, c^2 + d^2 <= a_ub*b*z)
    @constraint(m, c^2 + d^2 <= a*b_ub*z)
end


"`x - JuMP.upperbound(x)*(1-z) <= y <= x - JuMP.lowerbound(x)*(1-z)`"
function relaxation_equality_on_off(m, x, y, z)
    # assumes 0 is in the domain of y when z is 0

    x_ub = JuMP.upperbound(x)
    x_lb = JuMP.lowerbound(x)

    @constraint(m, y >= x - x_ub*(1-z))
    @constraint(m, y <= x - x_lb*(1-z))
end


"""
general relaxation of a square term

```
x^2 <= y <= (JuMP.upperbound(x)+JuMP.lowerbound(x))*x - JuMP.upperbound(x)*JuMP.lowerbound(x)
```
"""
function relaxation_sqr(m, x, y)
    @constraint(m, y >= x^2)
    @constraint(m, y <= (JuMP.upperbound(x)+JuMP.lowerbound(x))*x - JuMP.upperbound(x)*JuMP.lowerbound(x))
end


"""
general relaxation of binlinear term (McCormick)

```
z >= JuMP.lowerbound(x)*y + JuMP.lowerbound(y)*x - JuMP.lowerbound(x)*JuMP.lowerbound(y)
z >= JuMP.upperbound(x)*y + JuMP.upperbound(y)*x - JuMP.upperbound(x)*JuMP.upperbound(y)
z <= JuMP.lowerbound(x)*y + JuMP.upperbound(y)*x - JuMP.lowerbound(x)*JuMP.upperbound(y)
z <= JuMP.upperbound(x)*y + JuMP.lowerbound(y)*x - JuMP.upperbound(x)*JuMP.lowerbound(y)
```
"""
function relaxation_product(m, x, y, z)
    x_ub = JuMP.upperbound(x)
    x_lb = JuMP.lowerbound(x)
    y_ub = JuMP.upperbound(y)
    y_lb = JuMP.lowerbound(y)

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
    @assert JuMP.lowerbound(x) <= 0 && JuMP.upperbound(x) >= 0
    @assert JuMP.lowerbound(y) <= 0 && JuMP.upperbound(y) >= 0
    @assert JuMP.lowerbound(z) <= 0 && JuMP.upperbound(z) >= 0

    x_ub = JuMP.upperbound(x)
    x_lb = JuMP.lowerbound(x)
    y_ub = JuMP.upperbound(y)
    y_lb = JuMP.lowerbound(y)

    @constraint(m, z >= x_lb*y + y_lb*x - ind*x_lb*y_lb)
    @constraint(m, z >= x_ub*y + y_ub*x - ind*x_ub*y_ub)
    @constraint(m, z <= x_lb*y + y_ub*x - ind*x_lb*y_ub)
    @constraint(m, z <= x_ub*y + y_lb*x - ind*x_ub*y_lb)
end


"""
convex hull relaxation of trilinear term

```
w₁ = JuMP.lowerbound(x)*JuMP.lowerbound(y)*JuMP.lowerbound(z)
w₂ = JuMP.lowerbound(x)*JuMP.lowerbound(y)*JuMP.upperbound(z)
w₃ = JuMP.lowerbound(x)*JuMP.upperbound(y)*JuMP.lowerbound(z)
w₄ = JuMP.lowerbound(x)*JuMP.upperbound(y)*JuMP.upperbound(z)
w₅ = JuMP.upperbound(x)*JuMP.lowerbound(y)*JuMP.lowerbound(z)
w₆ = JuMP.upperbound(x)*JuMP.lowerbound(y)*JuMP.upperbound(z)
w₇ = JuMP.upperbound(x)*JuMP.upperbound(y)*JuMP.lowerbound(z)
w₈ = JuMP.upperbound(x)*JuMP.upperbound(y)*JuMP.upperbound(z)
w = λ₁*w₁ + λ₂*w₂ + λ₃*w₃ + λ₄*w₄ + λ₅*w₅ + λ₆*w₆ + λ₇*w₇ + λ₈*w₈
x = (λ₁ + λ₂ + λ₃ + λ₄)*JuMP.lowerbound(x) + (λ₅ + λ₆ + λ₇ + λ₈)*JuMP.upperbound(x)
y = (λ₁ + λ₂ + λ₅ + λ₆)*JuMP.lowerbound(x) + (λ₃ + λ₄ + λ₇ + λ₈)*JuMP.upperbound(x)
z = (λ₁ + λ₃ + λ₅ + λ₇)*JuMP.lowerbound(x) + (λ₂ + λ₄ + λ₆ + λ₈)*JuMP.upperbound(x)
λ₁ + λ₂ + λ₃ + λ₄ + λ₅ + λ₆ + λ₇ + λ₈ = 1
```
"""
function relaxation_trilinear(m, x, y, z, w, lambda)
    x_ub = JuMP.upperbound(x)
    x_lb = JuMP.lowerbound(x)
    y_ub = JuMP.upperbound(y)
    y_lb = JuMP.lowerbound(y)
    z_ub = JuMP.upperbound(z)
    z_lb = JuMP.lowerbound(z)

    @assert length(lambda) == 8

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
