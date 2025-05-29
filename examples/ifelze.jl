using Revise
using Dice 

a = flip(0.5) | flip(0.2)
b = uniform(DistUInt{3}, 2)
c = uniform(DistUInt{3}, 2)
d = ifelse(a, b, c)

println("Num Nodes: ", num_nodes(d))

# e = flip(0.5) | flip(0.2)
f = uniform(DistUInt{5}, 4)
g = uniform(DistUInt{5}, 4)
e = flip(0.5) | flip(0.2)
h = ifelse(e, f, g)
println("Num Nodes: ", num_nodes(h))

e = flip(0.5) | flip(0.2)
f = uniform(DistUInt{5}, 4)
g = uniform(DistUInt{5}, 4)
# e = flip(0.5) | flip(0.2)
h = ifelse(e, f, g)
println("Num Nodes: ", num_nodes(h))