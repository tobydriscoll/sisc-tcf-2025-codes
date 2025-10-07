# SISC paper on Thiele continued-fraction approximation

These files reproduce the results appearing in the manuscript "Greedy Thiele continued-fraction approximation on continuum domains in the complex plane," by Driscoll and Zhou.

The code was run on Julia 1.12.0-rc2 but should work at least as far back as version 1.10 of Julia.

## Installation

1. Clone the repository.
2. Start Julia in the repository directory with

``` shell
julia --project=.
```

3. Run

```julia
import Pkg; Pkg.instantiate()
```

That should install all the needed packages at the same versions used in the manuscript. (Some compile time will be needed for the graphics package.)

## Running the code

```julia
include("underresolved.jl")           # Fig. 3.1
include("cfrac-timing.jl")            # Table 4.1
include("comparison-interval.jl")     # Fig. 5.1, Table 5.1
include("comparison-circle.jl")       # Fig. 5.2, Table 5.2
```
