using Revise
using Dice 

a = flip(0.5) | flip(0.2) | flip(0.4)
b = uniform(DistUInt{3}, 2)
c = uniform(DistUInt{3}, 2)
d = ifelse(a, b, c)

println("Num Nodes: ", num_nodes(d))
# input_names = string.(get_flips(d) .|> x -> x.global_id)
# dump_dot(d, inames=input_names, filename="if-then-elze_manual.dot")


b = uniform(DistUInt{3}, 2)
c = uniform(DistUInt{3}, 2)
a = flip(0.5) | flip(0.2) | flip(0.4)
d = ifelse(a, b, c)

println("Num Nodes: ", num_nodes(d))
# input_names = string.(get_flips(d) .|> x -> x.global_id)
# dump_dot(d, inames=input_names, filename="if-then-elze.dot")


f = uniform(DistUInt{5}, 4)
g = uniform(DistUInt{5}, 4)
e = flip(0.5) | flip(0.2) | flip(0.4)
h = ifelse(e, f, g)
println("Num Nodes: ", num_nodes(h))

e = flip(0.5) | flip(0.2)
f = uniform(DistUInt{5}, 4)
g = uniform(DistUInt{5}, 4)
h = ifelse(e, f, g)
println("Num Nodes: ", num_nodes(h))