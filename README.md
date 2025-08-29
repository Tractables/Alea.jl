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

## Papers

This repository currently consists of code for the following papers:

[Tuning Random Generators: Property-Based Testing as Probabilistic Programming.](https://doi.org/10.1145/3763082) Ryan Tjoa, Poorva Garg, Harrison Goldstein, Todd Millstein, Benjamin Pierce, Guy Van den Broeck. OOPSLA 2025.
- Alea incorporates *Loaded Dice*, a discrete probabilistic programming system that supports differentiaton and parameter learning. The tutorials, linked in [Quick Start](#quick-start), cover parameter learning, and [pbt/](pbt/) contains examples in tuning generators for property-based testing.

[Bit Blasting Probabilistic Programs.](https://dl.acm.org/doi/10.1145/3656412) Poorva Garg, Steven Holtzen, Guy Van den Broeck, Todd Millstein. PLDI 2024.
- Alea incorporates *HyBit*, a bit blasting-based probabilistic programming system for discrete-continuous probabilistic programs. See [hybrid/](hybrid/) for more.

[Scaling Integer Arithmetic in Probabilistic Programs.](https://dl.acm.org/doi/10.5555/3625834.3625859) William X. Cao, Poorva Garg, Ryan Tjoa, Steven Holtzen, Todd Millstein, Guy Van den Broeck. UAI 2023.
