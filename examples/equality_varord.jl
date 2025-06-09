using Revise
using Dice

println("---- DistUInt Equality Benchmarks ----")

for (W, n) in [
    (3, 2), (4, 3), (5, 4), (6, 5), (7, 6),
    (8, 7), (10, 9), (12, 11), (16, 15), (20, 19), (26, 25)
]
    b = uniform(DistUInt{W}, n)
    c = uniform(DistUInt{W}, n)
    d = b == c
    println("Num nodes == DistUInt{$W} {$n} = ", num_nodes(d))
end
# 2W + n
# Num nodes == DistUInt{3} {2} should be 8
# Num nodes == DistUInt{4} {3} should be 11
# Num nodes == DistUInt{5} {4} should be 14
# Num nodes == DistUInt{6} {5} should be 17
# Num nodes == DistUInt{7} {6} should be 20
# Num nodes == DistUInt{8} {7} should be 23
# Num nodes == DistUInt{10} {9} should be 29
# Num nodes == DistUInt{12} {11} should be 35
# Num nodes == DistUInt{16} {15} should be 47
# Num nodes == DistUInt{20} {19} should be 59
# Num nodes == DistUInt{26} {25} should be 77

println("\n---- Mixed Equality + Arithmetic ----")

b = uniform(DistUInt{4}, 3)
c = uniform(DistUInt{4}, 3)
cc = uniform(DistUInt{4}, 3)
a = b + c + cc
d = uniform(DistUInt{4}, 3)
e = a == d
println("Nodes (a == d): ", num_nodes(e)) #38

b = uniform(DistUInt{10}, 9)
c = uniform(DistUInt{10}, 9)
d = b == c
println("Nodes (b == c) with W=10, n=9: ", num_nodes(d)) #29