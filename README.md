# Alea.jl

[![Unit Tests](https://github.com/Juice-jl/Dice.jl/workflows/Unit%20Tests/badge.svg)](https://github.com/Juice-jl/Dice.jl/actions?query=workflow%3A%22Unit+Tests%22+branch%3Amain)  [![codecov](https://codecov.io/gh/Tractables/Dice.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Tractables/Dice.jl)

Alea is a probabilistic programming system built in Julia, based on the discrete probabilistic programming language [Dice](https://github.com/SHoltzen/dice).

[Installation](#installation) | [Quick Start](#quick-start) | [Papers](#papers)

## Installation

Install Julia 1.8.5 or higher using [these instructions](https://julialang.org/downloads/platform/).

Then, install SymPy using the following command:

```bash
pip3 install sympy
```

Then, to install Alea and update dependencies:
```bash
julia --project -e "import Pkg;Pkg.update()"
```

One can now run a program from the Julia REPL (which can be opened with `julia --project`).

## Quick Start

Once the setup is complete, see [tutorial/tour_1_core.jl](tutorial/tour_1_core.jl) for a quick start to Alea. Then, see [tutorial/tour_2_learning.jl](tutorial/tour_2_learning.jl) for an introduction to learning probabilities.

Finally, see the following:

* [examples/](examples/) contains simple examples to get started with using Alea Julia package to write probabilistic programs.
* [test/](test/) contains unit test cases for all the functions and data types implemented.

## tddlog backend

By default `pr` compiles the queries and the evidence to a BDD with CUDD.
`algo = Tddlog()` instead hands the same Boolean circuit to
[tddlog](https://github.com/Tractables/tddlog), which compiles it bottom-up
into tree decision diagrams:

```julia
using Alea

x = uniform(DistUInt{4}, 0, 10) + DistUInt{4}(3)
pr(x; evidence = prob_equals(x, DistUInt{4}(5)) | flip(0.4), algo = Tddlog())
expectation(x; algo = Tddlog())
```

`Tddlog()` runs the command in `ENV["TDDLOG"]` or `tddlog` on the PATH;
`Tddlog(command = `...`)` names another. `write_problog(io, x)` writes the
circuit Alea builds for `x` (an `@alea` block's result, its observations as
evidence, or a distribution) as a ProbLog program without running
inference, so that tddlog can be run on it directly:

```julia
open(io -> write_problog(io, @alea begin
    a = flip(0.3)
    observe(a | flip(0.6))
    a
end), "program.pl", "w")
```

```bash
tddlog program.pl
```

Each Boolean of the value is a query `qK`, and each number a query
`qK(U)` for every world U of its bits that are not constant;
`write_problog(io, x; query = :expectation)` asks for each bit instead,
`eK(I)`, from which the expectation follows. Flips are named `fN` in the
order Alea created them. `write_problog` and `Tddlog` query at most 16 bits
that are not constant at once.

## Papers

This repository currently consists of code for the following papers:

[Tuning Random Generators: Property-Based Testing as Probabilistic Programming.](https://doi.org/10.1145/3763082) Ryan Tjoa, Poorva Garg, Harrison Goldstein, Todd Millstein, Benjamin Pierce, Guy Van den Broeck. OOPSLA 2025.
- Alea incorporates *Loaded Dice*, a discrete probabilistic programming system that supports differentiaton and parameter learning. The tutorials, linked in [Quick Start](#quick-start), cover parameter learning, and [pbt/](pbt/) contains examples in tuning generators for property-based testing.

[Bit Blasting Probabilistic Programs.](https://dl.acm.org/doi/10.1145/3656412) Poorva Garg, Steven Holtzen, Guy Van den Broeck, Todd Millstein. PLDI 2024.
- Alea incorporates *HyBit*, a bit blasting-based probabilistic programming system for discrete-continuous probabilistic programs. See [hybrid/](hybrid/) for more.

[Scaling Integer Arithmetic in Probabilistic Programs.](https://dl.acm.org/doi/10.5555/3625834.3625859) William X. Cao, Poorva Garg, Ryan Tjoa, Steven Holtzen, Todd Millstein, Guy Van den Broeck. UAI 2023.
