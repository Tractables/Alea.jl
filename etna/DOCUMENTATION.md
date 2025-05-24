# Etna

## Glossary

-   Broadly, we are trying to evaluate bug-finding effectiveness. As such, we
    (manually) insert _mutants_ into a program, and we test whether the program
    satisfies some _properties_. A _task_ is a mutant-property pair where the
    mutant causes the property to fail.

-   We organize tasks into _workloads_. Each of these workloads comes with some
    data type definitions, variant implementations of functions that use these
    types, and a property specification of these functions.

-   We evaluate PBT _strategies_, which are specific ways of using PBT
    _frameworks_ (like QuickCheck, for Haskell) to write generators.

-   We organize collections of things to evaluate into _experiments_.

## Navigation

There are three top-level folders in Etna:

-   `tool` contains the experiment driver, written in Python.

-   `experiments` contains the experiment scripts, also written in Python.

-   `workloads` contains the workloads, currently in Haskell and Coq.

### More About: `tool`

The experiment driver is responsible for toggling between variant
implementations, compiling and executing strategies, and collecting and
analyzing experiment data. The relevant code is in `tool/benchtool`.

First, consider `BenchTool.py`. This consists of an interface that each language
can implement. Some functions have default implementations based on the provided
configurations and some do not — e.g. the procedure for parsing and applying
mutants should be language-independent, while compilation is language-dependent.

Then, `Haskell.py` and `Coq.py` implement `BenchTool` — further details are
described in the sections below. New languages can be added in a similar fashion.

See `Types.py` for further documentation.

The files `Analysis.py` and `Plot.py` contain helper code to gather statistics
on and plot the data collected during an experiment, respectively.

### More About: `experiments`

The high-level structure of an experiment is that it instantiates a `BenchTool`
for a particular language and selects which tasks to execute.

Consider `experiments/haskell-experiments/4.1/Collect.py` as an example. This is
a Haskell experiment that runs all four currently available workloads on four
strategies — a bespoke, correct-by-construction generator and a naive generator
for each of the three currently available frameworks. The call to
`tool.apply_variant` builds the executable with the chosen variant, and the
`TrialConfig` sets up things like the number of trials to run and the timeout.

Current experiments can be modified or new experiments can be added; for
example, one might want to run a different subset of
workloads/strategies/properties, or with different configurations.

The `Analysis.py` file in the same folder generates "task bucket charts" for
each workload and compute the rate of solved tasks. The JSON data is parsed into
a `pandas` dataframe, so the user is also free to use the full force of the
`pandas` library to run the specific analyses they wish.

### More About: `workloads/Haskell`

There is a library of helper functions in `common/etna-lib`.

-   There is some common code that is shared across frameworks to run a strategy
    and output results. `Trial.hs` contains this code and `TH.hs` contains some
    TemplateHaskell to help the user avoid boilerplate.

-   Then, in the `Strategy` subfolder, there are implementations for the three
    frameworks currently supported: QuickCheck, SmallCheck, and LeanCheck.

    Since each framework has a slightly different interface and different ways
    of formatting results, we provide functions that translate our property
    types into the framework's property types, call the framework's "main"
    function, and translate the framework's result types into our result types.

    This is where the user should go if they want to add a new framework.

Currently, there are four workloads: BST, RBT, STLC, FSUB.

Each workload has in its `src` directory:

-   An `Impl.hs` containing the implementation (and mutants).
-   A `Spec.hs` containing the specification (i.e., properties).
-   A `Strategy` directory with one file per strategy.

New workloads can be added by following these conventions.

The Haskell-specific part of the Etna pipeline runs `stack build` to
build an executable with a variant implementation and `stack exec` with some
parameters to run the executable and collect data.

### More About: `workloads/Coq`

Currently, there are four workloads: BST, RBT, STLC, IFC. It also has a cleanup
script called `remove.sh` for removing all auto-generated files.

Each workload has:

-   A `Src` directory with the implementation and the specification.
-   A `Methods` directory with the generators.
-   A `Runners` directory with the runner files. Runners are auto-generated and
    allow Etna to extract property-tests to OCaml.
-   A `_CoqProject` file that defines the project files. Etna dynamically
    preprocesses this file to add the runners as they are generated.

The Coq-specific part of the Etna pipeline goes as follows (for QuickChick):

1. **Preprocessing:** For all methods, create their corresponding runner files
   and modify `_CoqProject`.
2. **Build Part 1:** Using the standard `coq_makefile`, run `make` on the
   project, creating the corresponding `.ml` files for each runner.
3. **Build Part 2:** Compile each `<runner>.ml` into a separate executable.

As before, this is all already handled by the driver.
