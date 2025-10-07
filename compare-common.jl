using RationalFunctionApproximation, ComplexRegions
using Latexify, CairoMakie, LaTeXStrings, JLD2
using Logging
global_logger(ConsoleLogger(stderr, Logging.Error))

function validate(r, fun, z, disallow)
    y = fun.(complex(z))
    n = length(r.history)
    deg = fill(0, n)
    err = zeros(n)
    disallowed = falses(n)
    best = 1
    for (k, h) in enumerate(r.history)
        r = h.interpolant
        deg[k] = degree(r)
        zp, ρ = residues(r)
        keep = @. abs(ρ) > 10eps(T)
        disallowed[k] = any(disallow.(zp[keep]))
        err[k] = maximum(abs, y - r.(z))
        if !disallowed[k] && (err[k] < err[best])
            best = k
        end
    end
    return deg, err, disallowed, best
end

function run_experiments(test_cases, domain, validation_points, sample_points, disallow; T=Float64, max_degree=120)
    bary = []
    thiele = []
    for (i, (desc, fun)) in enumerate(test_cases)
        println("Test case $i: $desc")

        # Find the full convergence curves
        rb = approximate(fun, domain; tol=100eps(T), method=Barycentric, max_iter=max_degree, allowed=true, stagnation=40)
        rt = approximate(fun, domain; tol=100eps(T), method=Thiele, max_iter=2max_degree, allowed=true, stagnation=18)
        bdeg, berr, bdisallowed, bbest = validate(rb, fun, validation_points, disallow)
        tdeg, terr, tdisallowed, tbest = validate(rt, fun, validation_points, disallow)

        # Reference error levels using discrete iterations
        rbd = approximate(fun, sample_points; tol=100eps(T), method=Barycentric, max_iter=max_degree, allowed=true, stagnation=24)
        bdiscrete = maximum(abs, fun.(validation_points) - rbd.(validation_points))
        rtd = approximate(fun, sample_points; tol=100eps(T), method=Thiele, max_iter=2max_degree, allowed=true, stagnation=18)
        tdiscrete = maximum(abs, fun.(validation_points) - rtd.(validation_points))

        # Timings out to "fair" comparison
        maxb = min(bbest, something(findfirst(@. !bdisallowed & (berr <= terr[tbest])), 100000))
        maxt = min(tbest, something(findfirst(@. !tdisallowed & (terr <= berr[bbest])), 100000))
        println("  Fair max iterations: Barycentric $maxb, Thiele $maxt")

        t0 = time_ns()
        for _ in 1:5
            approximate(fun, domain; tol=100eps(T), method=Barycentric, max_iter=maxb, allowed=true, stagnation=200)
        end
        time = (time_ns() - t0) / 5
        push!(bary, (;desc, time, approx=rb, err=berr, deg=bdeg, disallowed=bdisallowed, best=bbest, discrete=bdiscrete))

        t0 = time_ns()
        for _ in 1:5
            rt = approximate(fun, domain; tol=100eps(T), method=Thiele, max_iter=maxt, allowed=true, stagnation=200)
        end
        time = (time_ns() - t0) / 5
        push!(thiele, (;desc, time, approx=rt, err=terr, deg=tdeg, disallowed=tdisallowed, best=tbest, discrete=tdiscrete))
    end
    return bary, thiele
end

function make_plots(bary, thiele)
    fig = Figure(size=(1000, 700))
    pos = [(i,j) for j in 1:3, i in 1:2]
    ax = []
    for i in 1:6
        push!(ax, Axis(fig[pos[i]...],  yscale=log10, title=bary[i].desc))
        println(bary[i].desc)
        for (result, label, color) in zip([bary[i], thiele[i]], ["AAA", "TCF"], Makie.wong_colors()[1:2])
            bst = result.best
            scatterlines!(ax[i], result.deg[1:bst], result.err[1:bst]; color, markersize=6, alpha=0.5, label=label)
            hlines!(ax[i], [result.discrete]; linestyle=:dash, color, linewidth=2)
            scatter!(ax[i], result.deg[result.best], result.err[result.best]; color=RGBAf(1,1,1,0), strokecolor=:black, strokewidth=3, markersize=14 )
            dis = filter(<=(bst), findall(result.disallowed))
            scatter!(ax[i], result.deg[dis], result.err[dis]; color=:red, markersize=9, alpha=1, marker=:x)
        end
    end
    Legend(fig[3, 1:3], orientation=:horizontal, ax[1])
    return fig
end

function comparison_table(bary, thiele)
    tb = [b.time/1e6 for b in bary]
    tt = [t.time/1e6 for t in thiele]
    ratios = tb ./ tt
    return latexify(round.([tb tt ratios], digits=1))
end
