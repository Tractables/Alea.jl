using Revise
using Dice

a = flip(0.5)
b = DistUInt( [flip(0.0), a, flip(0.7), flip(0.8), flip(0.6)] )
c = DistUInt( [flip(0.0), flip(0.3), flip(0.4), flip(0.2), a] )
sum = b+c
input_names = string.(get_flips(sum) .|> x -> x.global_id)
# dump_dot(sum, inames=input_names, filename="multiple_indices.dot")
println("\tNum Nodes interdependent: ", num_nodes(sum))

a = flip(0.5)
b = DistUInt( [flip(0.0), flip(0.7), flip(0.8), flip(0.6), a] )
c = DistUInt( [flip(0.0), a, flip(0.3), flip(0.4), flip(0.2)] )
sum = b+c
input_names = string.(get_flips(sum) .|> x -> x.global_id)
println("\tNum Nodes interdependent: ", num_nodes(sum))

a = flip(0.5)
b = DistUInt( [flip(0.0), a, flip(0.7), a] )
c = DistUInt( [flip(0.0), a, a, a] )
sum = b+c
input_names = string.(get_flips(sum) .|> x -> x.global_id)
# dump_dot(sum, inames=input_names, filename="multiple_indices.dot")
println("\tNum Nodes interdependent: ", num_nodes(sum))


d = flip(0.5)
e = DistUInt( [flip(0.0), d, flip(0.5)])
f = DistUInt( [flip(0.0), flip(0.5), ifelse(d, flip(0.3), flip(0.7))])
g = e+f
input_names = string.(get_flips(g) .|> x -> x.global_id)
# dump_dot(g, inames=input_names, filename="interdependent.dot")
println("\tNum Nodes interdependent: ", num_nodes(g))


e = DistUInt( [flip(0.0), flip(0.2), flip(0.5)])
f = DistUInt( [flip(0.0), flip(0.5), ifelse(flip(0.9), flip(0.3), flip(0.7))])
g = e+f
input_names = string.(get_flips(g) .|> x -> x.global_id)
println("\tNum Nodes interdependent: ", num_nodes(g))

e = uniform(DistUInt{8},7)
f = DistUInt( [flip(0.0), flip(0.5), ifelse(flip(0.9), flip(0.3), flip(0.7)), flip(0.5), flip(0.5), flip(0.5), flip(0.5), flip(0.5)])
g = e+f
input_names = string.(get_flips(g) .|> x -> x.global_id)
println(input_names)
println("\tNum Nodes interdependent: ", num_nodes(g))