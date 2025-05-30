using Revise
using Dice 


# ------ Unit Tests ------
b = uniform(DistUInt{3}, 2)
c = uniform(DistUInt{3}, 2)
d = b < c
println("Num nodes {3} 2 = ", num_nodes(d))     # Should be 7

b = uniform(DistUInt{4}, 3)
c = uniform(DistUInt{4}, 3)
d = b < c
println("Num nodes {4} 3 = ", num_nodes(d))     # Should be 10

b = uniform(DistUInt{5}, 4)
c = uniform(DistUInt{5}, 4)
d = b < c
println("Num nodes {5} 4 = ", num_nodes(d))     # Should be 13

b = uniform(DistUInt{6}, 5)
c = uniform(DistUInt{6}, 5)
d = b < c
println("Num nodes {6} 5 = ", num_nodes(d))     # Should be 16

b = uniform(DistUInt{7}, 6)
c = uniform(DistUInt{7}, 6)
d = b < c
println("Num nodes {7} 6 = ", num_nodes(d))     # Should be 19

b = uniform(DistUInt{8}, 7)
c = uniform(DistUInt{8}, 7)
d = b < c
println("Num nodes {8} 7 = ", num_nodes(d))     # Should be 22

b = uniform(DistUInt{10}, 9)
c = uniform(DistUInt{10}, 9)
d = b < c
println("Num nodes {10} 9 = ", num_nodes(d))     # Should be 28

b = uniform(DistUInt{12}, 11)
c = uniform(DistUInt{12}, 11)
d = b < c
println("Num nodes {12} 11 = ", num_nodes(d))     # Should be 34

b = uniform(DistUInt{16}, 15)
c = uniform(DistUInt{16}, 15)
d = b < c
println("Num nodes {16} 15 = ", num_nodes(d))     # Should be 46

b = uniform(DistUInt{20}, 19)
c = uniform(DistUInt{20}, 19)
d = b < c
println("Num nodes {20} 19 = ", num_nodes(d))     # Should be 58

b = uniform(DistUInt{26}, 25)
c = uniform(DistUInt{26}, 25)
d = b < c
println("Num nodes {26} 25 = ", num_nodes(d))     # Should be 76

# -- END UNIT TESTS


b = uniform(DistUInt{4}, 3)
c = uniform(DistUInt{4}, 3)
cc = uniform(DistUInt{4}, 3)
a = b+c+cc
d = uniform(DistUInt{4}, 3)
e = a < d

println("Num nodes (e) = ", num_nodes(e))

b = uniform(DistUInt{10}, 9)
c = uniform(DistUInt{10}, 9)
d = b <= c

println("Num nodes (d) = ", num_nodes(d))

