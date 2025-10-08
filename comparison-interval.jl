# Reproduce data for Figure 5.1 and Table 5.1
include("compare-common.jl")

T, max_degree = (Float64, 120)
domain = Segment{T}(-1, 1)
t1 = T(2).^(-100:1//10:-1)
t2 = (-5000:5000) / T(5000)
validation_points = union(collect(t1), collect(-t1), collect(t2), collect(t1 .- 1))
t1 = T(2).^(-52:1//10:-1)
t2 = (-5000:5000) / T(5000)
sample_points = union(collect(t1), collect(-t1), collect(t2), collect(t1 .- 1))

disallow(z) = (abs(z) <= 1) && isreal(z)

test_cases = [
    (desc=L"\sqrt{x}", fun=z->sqrt(complex(z))),
    (desc=L"|x|", fun=z->abs(z)),
    (desc=L"|x + 10^{-6}i|", fun=z->abs(z + 1im/T(10)^6)),
    (desc=L"\log(x + 1 + 10^{-6})", fun=z->log(complex(z) + 1 + 1e-6)),
    (desc=L"\arctan(10^6 x)", fun=z->atan(T(10)^6*z)),
    (desc=L"\cos(100x)", fun=z->cos(100z)),
]

##
# Run experiments
bary, thiele = run_experiments(test_cases, domain, validation_points, sample_points, disallow; T, max_degree);
# @save "comparison-interval-results.jld2" bary thiele

# @load "comparison-interval-results.jld2"

##
# Make plots
fig = make_plots(bary, thiele)
# save("comparison-interval.pdf", fig)

##
println(comparison_table(test_cases,bary, thiele))
fig
