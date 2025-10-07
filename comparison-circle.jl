# Reproduce data for Figure 5.2 and Table 5.2
include("compare-common.jl")

T, max_degree = (Float64, 100)
domain = ComplexRegions.Circle(T(0), T(1))
t1 = T(2).^(-52:1//10:-1)
t2 = (-5000:4999) / T(5000)
sample_points = -cispi.(union(collect(t1), collect(-t1), collect(t2)));

disallow(z) = abs(abs(z) - 1) < 10*eps(T)

test_cases = [
    (desc=L"\sqrt{1 + z}", fun=z->sqrt(1 + z)),
    (desc=L"|1 + z|", fun=z->abs(z + 1 )),
    (desc=L"|1 + z + 10^{-6}|", fun=z->abs(z + 1 + 1e-6)),
    (desc=L"\log(1 + z + 10^{-6})", fun=z->log(complex(z + 1 + 1e-6))),
    (desc=L"\sqrt{1 + 10^{-6} - z^2}", fun=z->sqrt(complex(1+1e-6-z^2))),
    (desc=L"z^{50}", fun=z->z^50),
]

##
# Run experiments
bary, thiele = run_experiments(test_cases, domain, validation_points, sample_points, disallow; T, max_degree);
# @save "comparison-circle-results.jld2" bary thiele

# @load "comparison-circle-results.jld2"

##
# Make plots
fig = make_plots(bary, thiele)
# save("comparison-circle.pdf", fig)

##
println(comparison_table(test_cases, bary, thiele))
fig
