# Artifact for Tuning Random Generators

# Introduction

This is the artifact for "Tuning Random Generators: Property-Based Testing as
Probabilistic Programming." The paper proposes probabilistic programming
techniques to improve the distributions of random generators used for
property-based testing.

The artifact is distributed as a `.tar` file containing the following main
components:
- This `README.md`.
- The source for *Loaded Dice*, the probabilistic progamming language we present for the purpose of writing generators.
- Tour-style tutorials of Loaded Dice, which are described in
  [DOCUMENTATION.md](./DOCUMENTATION.md), and example tuning of generators.
- A Docker image from which the figures and benchmarks can be reproduced..

The claims in the paper are as follows:
1. Tuning can change a generator's distribution to approximate a target distribution.
   - This is supported by the artifact as it reproduces Figures 2 and 12b, which show generator distributions before and after tuning for a target distribution.
2. Specification entropy with regularization can increase the unique and valid
  generations, significantly more so than tuning for validity or
  entropy alone.
   - This is supported by the artifact as it reproduces Figures 3 and 4, which
    show cumulative unique generations before and after tuning an STLC generator
    and RBT generator for specification entropy with regularation. Figure 4 also
    shows that specification entropy results in more unique, valid generations
    than tuning for validity or entropy alone.
3. Regularization via bounded weights can greatly increase the unique and valid generations when tuning for specification entropy.
   - This is supported by the artifact as it reproduces Figure 10, as it tunes an RBT generator for specification entropy with and without regularization, and shows that regularization results in more unique and valid generations.
4. Tuning generators can notably improve bug-finding performance.
   - This is supported by the artifact as is reproduces our experiments on the Etna benchmark, reproducing Figures 11 and 12 and Table 1, which show that bug-finding speed of tuned generators outperforms both the untuned versions and their analogous versions from Etna.

# Hardware Dependencies

There are two main tasks performed by the artifact, with varying computational requirements:
1. **Running Etna.**  This has modest hardware requirements. It is recommended but not required to run this on a machine with many available cores, as these benchmarks are set up to automatically parallelize to complete faster.
2. **Tuning generators.** Tuning generators may take a significant amount of RAM (16 GB or more is recommended), and takes several hours for some figures (many samples and epochs are taken to show the graphs in high detail.) To ameliorate this, the artifact takes two measures:
      1. A `--fast` flag can be passed to the script for tuning generators (`run.py`), which performs more modest versions of the experiments.
      2. Tuning generators is deterministic as it uses seeded randomness. Thus, we include the results from previous tunings, which can be used instead for running Etna benchmarks.

More detail on employing the workarounds described follows in the instructions below.

# Getting Started (Docker)

> Note: using the included Docker image is recommended, but if one wishes to set up their environment themself, see [Instructions (Manual)](#instructions-manual).

First, install Docker: https://www.docker.com/get-started/.

Load the Docker image from `artifact-image.tar`:
```bash
docker load -i artifact-image.tar
```

> Aside: Should it be necessary, a Docker image can be rebuilt from `docker build -t artifact-image .`

Now, start and enter a container with:
```bash
docker run -it --name artifact-container artifact-image bash
```

From within the container, run the following to "kick-the-tires." This runs all parts of the artifact using previously cached results. Each command should take less than five minutes.
```bash
./run.py --all --parallel
./etna.py
```

If either command fails, see [Troubleshooting](#troubleshooting). Hopefully, all went well, in which case you can exit the Docker container, then copy the results with:

```bash
docker cp artifact-container:/app/experiments-output ./experiments-output-kick-tires
```

We explain what's happening in the commands above, and how to interpret the
results, in the detailed instructions below.

# Detailed Instructions

We first give an overview of how the artifact is structured and caches results in [Artifact structure](#artifact-structure). We then detail how to run the artifact to generate fresh results in [Running the artifact](#running-the-artifact). Finally, we describe how to interpret results with respect to the paper's claims in [Interpreting results](#interpreting-results).

## Artifact structure

### Loaded Dice

Loaded Dice and associated libraries for tuning generators are written in Julia.
It tunes and generators then exports them as Rocq.
The entry point for generator tuning is a `experiments/tool.jl`, which is invoked as a command line tool by `run.py` in this artifact.

### Etna

Etna provides Python benchmark harness supporting multiple languages; we use its Rocq benchmarks.
It is stored at `lib/etna`. It is invoked by `etna.py` in this artifact.

### Cached results

Below are directories containing various stages of pre-cached results.

- `tuning-output`
  * Caches tuned generators and associated data; created by `run.py`.
- `lib/etna/data-artifact`
  * Caches Etna run data; created by `etna.py`.
- `lib/etna/figures-artifact`
  * Caches Etna run data analysis; created by `etna.py`.
- `experiments-output`
  * Caches figures generated from `tuning-output` and `lib/etna/figures-artifact`.
  * Both `run.py` and `etna.py` populate this folder, depending on the figure.

## Running the artifact

As before, start and enter the container with the following:

> Note: if the container already exists, first remove it with `docker rm artifact-container`

```bash
docker run -it --name artifact-container artifact-image bash
```

This time, run the following to remove the final figures, as well as the `etna` results.
```bash
rm -rf lib/etna/data-artifact lib/etna/figures-artifact experiments-output
```

Now, we run `run.py`. Choose from one of these sets of arguments depending on your machine capabilities:
```bash
# Re-tunes generators from scratch. Takes around 8 hours (may vary by machine).
./run.py --all --force --parallel 

# Performs cheaper versions of some experiments, resulting in different plots
# for Figures 2, 3, 4, 10, but ones that should still show the same relative
# relationships between generators.
./run.py --all --force --fast --parallel

# Re-use the cached results. Takes less than 5 minutes.
./run.py --all --parallel
```

> Note: passing `--force` will overwrite old data. If a run is interrupted or fails partway through, then the container may need to be recreated from the image.

Then, as before, run:
```bash
./etna.py
```

Finally, exit the container and copy the experiment results:
```bash
docker cp artifact-run:/app/experiments-output ./experiments-output-full
```

## Interpreting results

The following files should be in `experiments-output-full`.
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

For Figures 2, 3, 4, 10, and 12b, the graph should match those in the paper
exactly (modulo LaTeX vs matplotlib render styling differences).

Figures 11 and 12b depend on the particular Etna run, so will differ. They 
should be similar, but the important properties should be quantitively compared
by consulting table1.txt. To verify that our claim is supported, the Speedup vs
Etna and Speedup vs Untuned columns should be significantly greater than 1.
Below is the range of results we've seen from 3 different runs (given the number
of numbers in this table, it is likely that at least one of your numbers are
slightly out if this range if your table is generated from a fresh Etna run.)

```
 Generator & Workload  │  Speedup vs Etna  │  Speedup vs Untuned  │
─────────────────────────────────────────────────────────────────────
BST Type-based         │       3.2x - 8.0x │          5.0x - 6.1x │
RBT Type-based         │       5.1x - 5.3x │          5.7x - 7.2x │
STLC Type-based        │       5.0x - 5.7x │          3.0x - 3.3x │
STLC Bespoke           │       2.3x - 2.6x │          1.7x - 2.0x │
```

We truncate training time as it is an abosulte time, and we expect it to be
relatively machine-dependent.

# Reusability guide

TODO_ARTIFACT: some intro sentence that shows we take this seriously

See [DOCUMENTATION](./DOCUMENTATION.md) for tutorials and examples of tuning
generators.

The source code of the probabilistic programming system used in this artifact is included, documented, and tested at [`lib/Dice.jl`](./lib/Dice.jl/). It is under active development here: https://github.com/Tractables/Alea.jl.

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

`--all` will always generate all figures, but individual figures can also be prepared with `--fig1`, `--fig2`, `--fig3`, `--fig4`, `--fig10`, `--fig11`, `--fig12`. All figures will produce all corresponding files in `experiments-output` except for Figures 11 and 12, as those prepare generators for Etna.

Also see `./run.py --help`.

## `etna.py`

To troubleshoot an error, re-run with `./etna.py --verbose`.

# Setup (Manual)

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
