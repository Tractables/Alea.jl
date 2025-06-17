# Artifact for Tuning Random Generators

## Setup (Docker)

```
# Build the container
docker build -t artifact .
docker run --name artifact-run artifact bash -c "./run.py --all --parallel"
<!-- TODO_ARTIFACT: use the below command instead, which also runs etna -->
<!-- docker run --name artifact-run artifact bash -c "./run.py --all --parallel && ./etna.py" -->

docker cp artifact-run:/app/experiments-output ./experiments-output




# my command for debugging
docker run -it artifact bash -c "./run.py --all --parallel && ./etna.py; bash"

docker run -it artifact bash -c "./run.py --all --parallel && ./etna.py"

# Run the container with kick-the-tires (fast check)
docker run -it artifact bash -c "eval \$(opam env) && ./run.py --fast --parallel && ./etna.py"

# Run the full experiments (takes several hours)
docker run -it artifact

# Run interactively to explore
docker run -it artifact bash
```

This document describes how to reproduce the figures in the paper. To make our
systems reusable, we also include "tour"-style tutorials of Loaded Dice, which
are described in [DOCUMENTATION.md](./DOCUMENTATION.md).

## Kick-the-tires

```
docker run -it artifact bash -c "eval \$(opam env) && ./run.py --all --parallel && ./etna.py
```

We have committed results from training and Etna to allow for a "kick-the-tires"
check on the artifact infrastructure. To do so, first follow instructions in 
this document as instructed. When possible, cached results should be used, so no
single command should take more than a few seconds.

Then, to reproduce the results from scratch, delete the following directories
and re-run the instructions in [Reproducing Figures](#reproducing-figures):
- `experiments-output`
- `lib/etna/data-artifact`
- `lib/etna/figures-artifact`

# Instructions

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
opam pin coq 8.15.2
```

# Reproducing figures

From the repository root, run:
```bash
./run.py --all --parallel
./etna.py
```

This is expected to take a few hours to run. See
[Troubleshooting](#troubleshooting) if errors occur.
Then, the following files should be in `experiments-output`:

```
fig2_rbt_type_based_linear.png  
fig2_rbt_type_based_uniform.png
fig2_stlc_bespoke_linear.png     
fig2_stlc_bespoke_uniform.png    
fig2_stlc_type_based_linear.png 
fig2_stlc_type_based_uniform.png
fig11a_bst_type_based_times.png
fig11b_rbt_type_based_times.png
fig11c_stlc_type_based_times.png  
fig12b_dist.png                 
fig12a_stlc_bespoke_times.png
table1.txt
```

# Verifying results

For Figures 2, 3, 4, 10, and 12b, the graph should match those in the paper
exactly (modulo LaTeX vs matplotlib render styling differences).

Figures 11 and 12b depend on the particular Etna run, so will differ. They 
should be similar, but the important properties should be quantitively compared
by consulting table1.txt.

TODO: give bounds

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
