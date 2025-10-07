# Reproduce timings for Table 4.1

using PrettyTables

function eval1(a, b)
    n = length(b)
    r = b[n]
    @inbounds for k in n-1:-1:1
        r = b[k] + a[k] / r
    end
    return r
end
function eval2(a, b)
    n = length(b)
    p₊ = b[n]
    q₊ = a[n-1]
    @inbounds for k in n-1:-1:2
        p = b[k] * p₊ + q₊
        q = a[k-1] * p₊
        p₊ = p
        q₊ = q
    end
    return b[1] + q₊ / p₊
end

function mybench(method, n, evals=1_000_000; docomplex=false)
    t = 0
    for _ in 1:evals
        a = docomplex ? complex.(randn(n), randn(n)) : randn(n)
        b = docomplex ? complex.(randn(n+1), randn(n+1)) : randn(n+1)
        start = time_ns()
        method(a, b)
        t += time_ns() - start
    end
    return float(t) / evals
end

##
t1r = []
t2r = []
docomplex = false
for n in 25:5:50
    push!(t1r, mybench(eval1, n, 3_000_000; docomplex))
    push!(t2r, mybench(eval2, n, 3_000_000; docomplex))
end
println("real results")
pretty_table(
    hcat(25:5:50, t1r, t2r, t1r ./ t2r),
    column_labels = ["n", "eval1 (ns)", "eval2 (ns)", "ratio"],
    formatters = [fmt__printf("%.1f", 2:3), fmt__printf("%.1f%", [4])],
)

t1c = []
t2c = []
docomplex = true
for n in 25:5:50
    push!(t1c, mybench(eval1, n, 3_000_000; docomplex))
    push!(t2c, mybench(eval2, n, 3_000_000; docomplex))
end
println("\ncomplex results")
pretty_table(
    hcat(25:5:50, t1c, t2c, t1c ./ t2c),
    column_labels = ["n", "eval1 (ns)", "eval2 (ns)", "ratio"],
    formatters = [fmt__printf("%.1f", 2:3), fmt__printf("%.1f%", [4])],
)

##
println("\ncombined results")
pretty_table(
    hcat(25:5:50, t1r, t2r, t1r ./ t2r, t1c, t2c, t1c ./ t2c),
    column_labels = ["n", "eval1 (ns)", "eval2 (ns)", "ratio", "eval1 (ns)", "eval2 (ns)", "ratio"],
    formatters = [fmt__printf("%.1f", [2:3; 5:6]), fmt__printf("%.1f", [4; 7])],
    backend=:latex
)
