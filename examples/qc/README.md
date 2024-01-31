# Learning generator probabilities in Dice

Once the installation ([`../../README.md`](../../README.md)) is complete, see [`examples/tour_1_core.jl`](examples/tour_1_core.jl) for a quick start to Dice.jl. Then, see [`examples/tour_2_learning.jl`](examples/tour_2_learning.jl) for an introduction to learning probabilities with MLE in Dice.jl.

The following related programs are included. The expected output of each is in a comment at the bottom of the file.
- Generator for nat lists ([`examples/demo_natlist.jl`](examples/demo_natlist.jl))
  - Given a generator for nat lists with a hole dependent on size, chooses probabilities such that the list has uniform length.
- Generator for sorted nat lists ([`examples/demo_sortednatlist.jl`](examples/demo_sortednatlist.jl))
  - Given a generator for sorted nat lists with a hole dependent on size, chooses probabilities such that the list has uniform length.
- Generator for binary search trees ([`examples/demo_bst.jl`](examples/demo_bst.jl))
  - Given a generator for binary search trees with a hole dependent on size, chooses probabilities such that the tree has uniform depth.
  - 50 example generated BSTs are visible at [`examples/samples/bst.txt`](examples/samples/bst.txt)
- Generator for closed untyped lambda calculus expressions ([`examples/demo_utlc.jl`](examples/demo_utlc.jl))
  - Given a generator for UTLC exprs with a hole dependent on size, chooses probabilities such that the AST has near uniform depth
  - 50 example generated expressions are visible at [`examples/samples/utlc.txt`](examples/samples/utlc.txt).
- Generator for well-typed, simply-typed lambda calculus expressions ([`benchmarks`](benchmarks))
  - Configure and run [`benchmarks/main.jl`](benchmarks/main.jl)

Beware that the programs expected to run on this version of Dice.jl are the examples listed above and the tests. Other examples are known to be broken.
