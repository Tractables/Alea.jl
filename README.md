# Artifact for Tuning Random Generators

# Introduction

This is the artifact for "Tuning Random Generators: Property-Based Testing as
Probabilistic Programming." The paper proposes probabilistic programming
techniques to improve the distributions of random generators used for
property-based testing.

The artifact is distributed as a `TODO-COMPRESS` file containing the following
main components:
- This README
- The source for *Loaded Dice*, the probabilistic progamming language we present
  for the purpose for writing generators.
- "Tour"-style tutorials of Loaded Dice, which are described in
  [DOCUMENTATION.md](./DOCUMENTATION.md), and example tuning of generators.
- A Docker image from which the figures and benchmarks can be reproduced.

This document describes how to reproduce the figures in the paper. To make our
systems reusable, we also include 

# Instructions (Docker)

Install Docker. To build the container:

```
docker load -i artifact.tar
```

docker run --name artifact-run artifact bash -c "./run.py --all --parallel; ./etna.py"

```
docker build -t artifact .
```

We have committed results from training and Etna to allow for a "kick-the-tires"
check on the artifact infrastructure. When possible, cached results should be
used, so no single command should take more than a few seconds. To test the
artifact using these cached results, run the following.

```
docker run --name artifact-run artifact bash -c "./run.py --all --parallel"
docker cp artifact-run:/app/experiments-output ./experiments-output-kick-tires
```

To clean up the docker container, run the following.
```
docker rm artifact-run
```

Now, run the following to reproduce the results from scratch, then see the contents of `experiments-output-full`.
```
docker run --name artifact-run artifact bash -c "rm experiments-output lib/etna/data-artifact lib/etna/figures-artifact"
docker run --name artifact-run artifact bash -c "./run.py --all --parallel"
docker cp artifact-run:/app/experiments-output ./experiments-output-full
```

```
TODO_ARTIFACT: use the below command instead, which also runs etna, once we can get QuickChick to build
docker run --name artifact-run artifact bash -c "./run.py --all --parallel && ./etna.py"
```

### Upon success

success, the following files should be in `experiments-output`.
```
fig2_rbt_type_based_linear.png  
fig2_rbt_type_based_uniform.png
fig2_stlc_bespoke_linear.png     
fig2_stlc_bespoke_uniform.png    
fig2_stlc_type_based_linear.png 
fig2_stlc_type_based_uniform.png
fig3a_stlc_unique_types_dist.png
fig3b_stlc_cumulative_unique_types.svg
fig4_cumulative_unique_types.png
fig10_cumulative_unique_types.png
fig11a_bst_type_based_times.png
fig11b_rbt_type_based_times.png
fig11c_stlc_type_based_times.png  
fig12a_stlc_bespoke_times.png
fig12b_dist.png                 
table1.txt
```

# Verifying results

For Figures 2, 3, 4, 10, and 12b, the graph should match those in the paper
exactly (modulo LaTeX vs matplotlib render styling differences).

Figures 11 and 12b depend on the particular Etna run, so will differ. They 
should be similar, but the important properties should be quantitively compared
by consulting table1.txt.

```
TODO_ARTIFACT: give bounds. below are examples from three runs

 Generator & Workload  │  Speedup vs Etna  │  Speedup vs Untuned  │  Train Time 
────────────────────────────────────────────────────────────────────────────────
BST Type-based         │              3.5x │                 5.4x │        3m
RBT Type-based         │              5.3x │                 5.7x │        3m
STLC Type-based        │              5.5x │                 3.2x │        7m
STLC Bespoke           │              2.3x │                 1.9x │        8ms

 Generator & Workload  │  Speedup vs Etna  │  Speedup vs Untuned  │  Train Time 
────────────────────────────────────────────────────────────────────────────────
BST Type-based         │              3.6x │                 5.2x │        2m49s
RBT Type-based         │              5.3x │                 5.7x │         3m4s
STLC Type-based        │              5.5x │                 3.2x │        6m49s
STLC Bespoke           │              2.4x │                 1.7x │        7m54s

 Generator & Workload  │  Speedup vs Etna  │  Speedup vs Untuned  │  Train Time 
────────────────────────────────────────────────────────────────────────────────
BST Type-based         │              3.2x │                 5.0x │        3m17s
RBT Type-based         │              5.1x │                 7.0x │        3m30s
STLC Type-based        │              5.0x │                 3.3x │        7m46s
STLC Bespoke           │              2.5x │                 2.0x │         9m5s

 Generator & Workload  │  Speedup vs Etna  │  Speedup vs Untuned  │  Train Time 
────────────────────────────────────────────────────────────────────────────────
BST Type-based         │              3.8x │                 6.1x │        
RBT Type-based         │              5.3x │                 7.2x │        
STLC Type-based        │              5.7x │                 3.0x │        
STLC Bespoke           │              2.6x │                 2.0x │        

```

# Reusability guide



# Troubleshooting

## `run.py`

These arguments always apply.
- `--fast` runs "lightweight" versions of the experiments that should complete
  faster, with results that align with the conclusions of the paper but to
  a lesser degree (e.g. training for fewer epochs to reduce training time,
  but obtaining a less optimal generator)
- `--verbose` prints extra information.
- `--parallel` parallelizes invocations of generator training.

In particular, if something is too resource-intensive, include `--fast`.
If something breaks, remove `--parallel` and include `--verbose`.

Also see `./run.py --help`.

## `etna.py`

To troubleshoot an error, re-run with `./etna.py --verbose`.

# Instructions (Manual)

## Julia setup

Install Julia 1.10. Then run the following from the root of the directory:

```
julia --project -e 'using Pkg; Pkg.instantiate()'
julia --project -e 'using Pkg; Pkg.develop(path="lib/IRTools.jl")'
julia --project -e 'using Pkg; Pkg.develop(path="lib/CUDD.jl")'
julia --project -e 'using Pkg; Pkg.develop(path="lib/Dice.jl")'
```

## Python setup

Install Python 3.10.13
Install numpy, pandas 1.5.3, and matplotlib

install benchtool:
cd lib/etna/tool && pip install -e .

## Coq setup

Install opam, then:

```bash
opam switch create 4.10.0+afl
opam pin coq 8.15.0
```

# Reproducing figures

From the repository root, run:
```bash
./run.py --all --parallel
./etna.py
```

From a fresh state of the artifact, this should take less than 5 minutes,
as the results are cached. To regenerate the results, re-run the above scripts
after deleting the following directories, which should then take a few hours to
run.
- `tuning-output`
- `lib/etna/data-artifact`
- `lib/etna/figures-artifact`
- `experiments-output`

For a run, see [Troubleshooting](#troubleshooting) if errors occur. Upon