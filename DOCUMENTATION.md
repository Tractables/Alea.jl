# Setup

Follow [README.md#julia-setup](README.md#julia-setup).

Recommended: to run and tinker with the tutorials line-by-line, also install the
Julia VSCode extension.

# Learning generator probabilities in Dice

Once the setup is complete, see [`tutorial/tour_1_core.jl`](tutorial/tour_1_core.jl) for a quick start to Loaded Dice. Then, see [`tutorial/tour_2_learning.jl`](tutorial/tour_2_learning.jl) for an introduction to learning probabilities.

The following related programs are included. The expected output of each is in a comment at the bottom of the file.
- Generator for nat lists ([`examples/demo_natlist.jl`](examples/demo_natlist.jl))
  - Given a generator for nat lists with a hole dependent on size, chooses probabilities such that the list has a particular distribution on lengths.
- Generator for binary search trees ([`examples/demo_bst.jl`](examples/demo_bst.jl))
  - Given a generator for binary search trees with a hole dependent on size, chooses probabilities such that the tree has uniform depth.
  - 50 example generated BSTs are visible at [`examples/samples/bst.txt`](examples/samples/bst.txt)
