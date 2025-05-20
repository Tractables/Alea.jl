using Revise
using Dice

a = uniform(DistUInt{3}, 2)
b = uniform(DistUInt{3}, 2)
c = uniform(DistUInt{3}, 2)
sum = a+b+c
input_names = string.(get_flips(sum) .|> x -> x.global_id)
print("\tNUM NODES ADD a+b+c {3}, 2 = ", num_nodes(sum))

a = uniform(DistUInt{3}, 2)
b = uniform(DistUInt{3}, 2)
c = uniform(DistUInt{3}, 2)
d = a+b
sum = d+c
input_names = string.(get_flips(sum) .|> x -> x.global_id)
print("\tNUM NODES ADD a+b+c {3}, 2 = ", num_nodes(sum))
