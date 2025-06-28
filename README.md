# Artifact for Tuning Random Generators

# Introduction

This is the artifact for "Tuning Random Generators: Property-Based Testing as
Probabilistic Programming." The paper proposes probabilistic programming
techniques to improve the distributions of random generators used for
property-based testing.

## Basic Organization

The artifact is distributed as `artifact.tgz`. Decompress this with the following command:
```bash
tar -xvzf artifact.tgz
```

This yields one directory. We highlight a few key files/subdirectories.
- `artifact/`
  * `artifact-image.tar`: The Docker image used to run the artifact.
  * `src/`: The source for *Loaded Dice*, the probabilistic progamming language we present for the purpose of writing generators.
  * `DOCUMENTATION.md`: Pointers to tour-style tutorials of Loaded Dice and example generator tunings.
  * `README.md`: This README.

From here on, this README assumes that the present working directory is `artifact`.

## Claims Supported

The claims in the paper are as follows:
1. Tuning can change a generator's distribution to approximate a target distribution.
   - This is supported by the artifact as it reproduces Figures 2 and 12b, which show generator distributions before and after tuning for a target distribution.
2. Specification entropy with regularization can increase the unique and valid
  generations, significantly more so than tuning for validity or
  entropy alone.
   - This is supported by the artifact as it reproduces Figures 3, 4 and 10, which
    show cumulative unique generations before and after tuning an STLC generator
    and RBT generator for specification entropy with regularization.
3. Regularization via bounded weights can greatly increase the unique and valid generations when tuning for specification entropy.
   - This is supported by the artifact as it reproduces Figure 10, as it tunes an RBT generator for specification entropy with and without regularization, and shows that regularization results in more unique and valid generations.
4. Tuning generators can notably improve bug-finding performance.
   - This is supported by the artifact as is reproduces our experiments on the Etna benchmark, reproducing Figures 11 and 12 and Table 1, which show that bug-finding speed of tuned generators outperforms both the untuned versions and their analogous versions from Etna.

# Hardware Dependencies


Our original experiments were ran on a server with 500 GB RAM. In order to make the artifact more accessible, we created cheaper versions of several experiments to support the same claims. With these cheaper versions, we were able to provide similar results for Figures 2, 3, 10, 11, 12, and Table 1, to support all claims, on a laptop with a 12th Gen Intel(R) Core(TM) i7-1260P processor and 64 GB RAM. We detail how to choose this parameterization in [Running the artifact](#running-the-artifact).

There are two main tasks performed by the artifact, with varying computational requirements:
1. **Running Etna.**  This has modest hardware requirements.
2. **Tuning generators.** Tuning generators may take a significant amount of RAM (16 GB or more is recommended), and takes several hours for some figures (many samples and epochs are taken to show the graphs in high detail.) To ameliorate this, the artifact takes two measures:
      1. A `--fast` flag can be passed to the script for tuning generators (`run.py`), which performs more modest versions of the experiments.
      2. Tuning generators is deterministic as it uses seeded randomness. Thus, we include the results from previous tunings, which can be used instead for running Etna benchmarks.

More detail on employing the workarounds described follows in the instructions below.

# Getting Started (Docker)

> Note: using the included Docker image is recommended, but if one wishes to set up their environment themself, see [Setup (Manual)](#setup-manual).

First, install Docker: https://www.docker.com/get-started/.

Load the Docker image from `artifact-image.tar` (this should take less than five minutes).
```bash
docker load -i artifact-image.tar
```

Upon success, the above will print `Loaded image: artifact-image:latest`. Now, start and enter a container with:
```bash
docker run -it --name artifact-container artifact-image bash
```

From within the container, run the following to "kick-the-tires." This runs all parts of the artifact using previously cached results. Each should take less than five minutes. Both commands print output, which can be ignored as long as they do not error.
```bash
./run.py --all --parallel
./etna.py
```

If either command fails, see [Script Documentation and Troubleshooting](#script-documentation-and-troubleshooting). Hopefully, all went well, in which case you can exit the Docker container, then copy the results with:

```bash
docker cp artifact-container:/app/experiments-output ./experiments-output-kick-tires
```

Now, all plots reported in the paper should be available in `./experiments-output-kick-tires`. For more detail on how to interpret these results, see [Interpreting results](#interpreting-results).

To reproduce these results from scratch, we provide instructions below.

# Detailed Instructions

We first give an overview of how the artifact is structured and caches results in [Artifact structure](#artifact-structure). We then detail how to run the artifact to generate fresh results in [Running the artifact](#running-the-artifact). Finally, we describe how to interpret results with respect to the paper's claims in [Interpreting results](#interpreting-results).

## Artifact structure

### Loaded Dice

Loaded Dice and associated libraries for tuning generators are written in Julia and contained in `src/`. It tunes and generators then exports them as Rocq.

The entry point for our generator tuning experiments is `experiments/tool.jl`, which is invoked as a command line tool by `run.py` in this artifact.

### Etna

Etna provides a Python benchmark harness supporting multiple languages; we use its Rocq benchmarks. It is stored at `lib/etna`, and invoked by `etna.py` in this artifact.

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

> Note: it is not necessary to remove the cached results in `./tuning-output`, as passing `--force` below will cause them to be recomputed and overwritten.

Now, we run `run.py`. We choose a variation of the artifact that should be able to be run on a laptop. The produces smaller-scale versions of the results from Figures 2, 3, and 10. It reproduces Figures 11 and 12 as they are in the paper (modulo nondeterminism due to timings).

```bash
./run.py --fig2 --fig3 --fig10 --force --fast # takes under an hour on our laptop
./run.py --fig11 --fig12 --force # takes under twenty minutes on our laptop
```

Notes:
1. These can also be further broken up into multiple invokations of `run.py`, by passing one `--figN` flag at a time.
2. Passing `--force` will overwrite old data. If a run is interrupted or fails partway through, then the container may need to be recreated from the image.
3. To reproduce Figures 2, 3, 4, and 10 as they are in the paper, run `./run.py --all --force` instead, which takes 8 hours on our server.

Then, as before, run the following. On our laptop, it takes 4-8 hours.
```bash
./etna.py
```

Finally, exit the container and copy the experiment results:
```bash
docker cp artifact-container:/app/experiments-output ./experiments-output
docker cp artifact-container:/app/experiments-output-fast ./experiments-output-fast
```

Now, all plots reported in the paper should be available in `./experiments-output-full`. For details on how to interpret these results, see below.

## Interpreting results

The following files should be in the experiments output folders copied from the Docker container:
```
experiments-output-fast/
    fig2_rbt_type_based_linear.png  
    fig2_rbt_type_based_uniform.png
    fig2_stlc_bespoke_linear.png     
    fig2_stlc_bespoke_uniform.png    
    fig2_stlc_type_based_linear.png 
    fig2_stlc_type_based_uniform.png
    fig3a_stlc_unique_types_dist.png
    fig3b_stlc_cumulative_unique_types.svg
    fig10_cumulative_unique_types.png
experiments-output/
    fig11a_bst_type_based_times.png
    fig11b_rbt_type_based_times.png
    fig11c_stlc_type_based_times.png  
    fig12a_stlc_bespoke_times.png
    fig12b_dist.png
    table1.txt
```

We detail how to interpret each figure.

### Figure 2

Each subplot should be very similar to the paper; the tuned distribution should be as a whole more similar to the objective distribution than the initial distribution.

### Figure 3a

This will differ visually if computed with `--fast`, but should show the same trend of the distribution of types becoming more diverse throughout training. In particular, the number of not well-typed terms should significantly shrink.

### Figure 3b

The "tuned" curve should be above the "intial" curve, indicating that the tuned generator produces more unique types.

## Figure 4 (if included)

The "specification entropy" curve should be above all others, indicating that it produces more unique, valid RBTs.

### Figure 10

The "specification entropy" curve should be above both "untuned" and "specification entropy without regularization" curves, indicating that it produces more unique, valid RBTs.

### Figures 11 and 12, and Table 1


Figures 11 and 12b depend on the particular Etna run due to the dependence on timing information, so will differ. They should be similar, but the important properties should be quantitively compared by consulting table1.txt. To verify that our claim is supported, the Speedup vs Etna and Speedup vs Untuned columns should be significantly greater than 1. Below is the range of results we've seen from 3 different runs (given the number of numbers in this table, it is likely that at least one of your numbers are slightly out if this range if your table is generated from a fresh Etna run.)

```
 Generator & Workload  │  Speedup vs Etna  │  Speedup vs Untuned  │
─────────────────────────────────────────────────────────────────────
BST Type-based         │       3.1x - 8.0x │          5.0x - 6.1x │
RBT Type-based         │       5.1x - 5.9x │          5.7x - 7.2x │
STLC Type-based        │       5.0x - 6.7x │          3.0x - 4.0x │
STLC Bespoke           │       2.0x - 2.6x │          1.7x - 2.0x │
```

We truncate training time as it is an absolute time and we expect it to be relatively machine-dependent.

# Reusability guide

We provide documentation, tutorials, and source code to support researchers and practitioners who wish to reuse or extend our work on tuning random generators.

See [DOCUMENTATION](./DOCUMENTATION.md) for tutorials and examples of tuning generators.

The source code of the probabilistic programming system used in this artifact is included, documented, and tested at [`lib/Dice.jl`](./lib/Dice.jl/). It is under active development here: https://github.com/Tractables/Alea.jl.

# Script Documentation and Troubleshooting

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

(This follows the instructions in `lib/etna/README.md`.)

Install Python 3.10.13.

Then, to install necessary packages:
```bash
pip install pandas==1.5.3 numpy==1.22.4 scipy==1.10.1 seaborn dash
pip install -r lib/etna/tool/requirements.txt
cd lib/etna/tool && pip install -e .
cd ../../..
```

## Coq setup

(This follows the instructions in `lib/etna/README.md`.)

Install Opam, then run the following. 

```bash
opam switch create 4.10.0+afl
opam pin coq 8.15.0
eval $(opam env)
cd lib/QuickChick
opam install . --deps-only -y
make
make install
cd ../..
```