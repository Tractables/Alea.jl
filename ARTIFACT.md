# Artifact for Tuning Random Generators

## Instructions

### Setup

```
julia --project -e 'using Pkg; Pkg.develop(path="lib/IRTools.jl")'
julia --project -e 'using Pkg; Pkg.develop(path="lib/CUDD.jl")'
julia --project -e 'using Pkg; Pkg.develop(path="lib/Dice.jl")'
julia --project -e 'using Pkg; Pkg.add("DataStructures")'
julia --project -e 'using Pkg; Pkg.add("DirectedAcyclicGraphs")'
julia --project -e 'using Pkg; Pkg.add("Combinatorics")'
julia --project -e 'using Pkg; Pkg.add("Plots")'
julia --project -e 'using Pkg; Pkg.add("Random")'
julia --project -e 'using Pkg; Pkg.add("JLD2")'
```

numpy pandas matplotlib


```
julia --project
]
develop lib/Dice.jl
develop lib/CUDD.jl
develop lib/IRTools.jl
add DataStructures
```

### Reproducing Figures 2, 3, 4, 10, 12b

From the repository root, run:
```
./run.py --all --parallel
```

This is expected to take a few hours to run.
Images

### Reproducing Etna Results (Figures 11, 12a)

### Troubleshooting

run.py is the main script for the artifact.

These arguments always apply.
- `--fast` runs "lightweight" versions of the experiments that should complete
  faster, with results that align with the conclusions of the paper but to
  a lesser degree (e.g. training for fewer epochs to reduce training time,
  but obtaining a less optimal generator)
- `--verbose` prints extra information.
- `--parallel` parallelizes invocations of generator training.
```

In particular, if something is too resource-intensive, include `--fast`.
If something breaks, remove `--parallel` and include `--verbose`.
