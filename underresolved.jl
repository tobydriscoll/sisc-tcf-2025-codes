# Reproduce Figure 3.1

using RationalFunctionApproximation
using CairoMakie
using LaTeXStrings

##
x = range(-1, 1, 1001)
f(x) = atan(500x)
y = f.(x)
r, history = approximate(y, x; tol=1e-14, method=Thiele, max_iter=200, stagnation=20)
maximum(abs(f(x) - r(x)) for x in x)

##
fig = Figure(size=(600,250))
ax = Axis(fig[1, 1], xlabel=L"x", ylabel=L"f(x)-r(x)")
lines!(ax, -5e-3..5e-3, x -> f(x)-r(x))
xx = filter(x->abs(x)<.005,x)
scatter!(ax, xx, f.(xx)-r.(xx), color=:black)
fig
# save("underresolved.pdf", fig)
