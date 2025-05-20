using Revise 
using Dice 

# --- Basic Unit tests for diff sizes -- 
d = uniform(DistUInt{3}, 2)
e = uniform(DistUInt{3}, 2)
f = d-e
# input_names = string.(get_flips(f) .|> x -> x.global_id)
print("\tNUM NODES SUB {3}, 2 = ", num_nodes(f))                # Should be 13
# dump_dot(f, inames=input_names, filename="threexthree.dot")

d = uniform(DistUInt{4}, 3)
e = uniform(DistUInt{4}, 3)
f = d-e
# input_names = string.(get_flips(f) .|> x -> x.global_id)
print("\tNUM NODES SUB {4}, 3= ", num_nodes(f))                 # Should be 22
# dump_dot(f, inames=input_names, filename="fourxfour.dot")

d = uniform(DistUInt{5}, 4)
e = uniform(DistUInt{5}, 4)
f = d-e
# input_names = string.(get_flips(f) .|> x -> x.global_id)
print("\tNUM NODES SUB {5}, 4= ", num_nodes(f))
# dump_dot(f, inames=input_names, filename="fivexfive.dot")   # Should be 31

d = uniform(DistUInt{8}, 7)
e = uniform(DistUInt{8}, 7)
f = d-e
# input_names = string.(get_flips(f) .|> x -> x.global_id)
print("\tNUM NODES SUB {8}, 7= ", num_nodes(f))                 # Should be 58
# dump_dot(f, inames=input_names, filename="eightxeight.dot")

d = uniform(DistUInt{10}, 9)
e = uniform(DistUInt{10}, 9)
f = d-e
# input_names = string.(get_flips(f) .|> x -> x.global_id)
print("\tNUM NODES SUB {10}, 9 = ", num_nodes(f))               # Should be 76

d = uniform(DistUInt{15}, 14)
e = uniform(DistUInt{15}, 14)
f = d-e
# input_names = string.(get_flips(f) .|> x -> x.global_id) 
print("\tNUM NODES SUB {15}, 14 = ", num_nodes(f)) 

d = uniform(DistUInt{20}, 19)
e = uniform(DistUInt{20}, 19)
f = d-e
# input_names = string.(get_flips(f) .|> x -> x.global_id)
print("\tNUM NODES SUB {20}, 19 = ", num_nodes(f)) 

d = uniform(DistUInt{31}, 30)
e = uniform(DistUInt{31}, 30)
f = d-e
# input_names = string.(get_flips(f) .|> x -> x.global_id)
print("\tNUM NODES SUB {31}, 30 = ", num_nodes(f))          # Should be 265

# -- End basic unit tests --

# If-then-else complicated
aa = DistUInt([flip(0.0), flip(0.5), flip(0.5), ifelse(flip(0.5), flip(0.4), flip(0.6))])
bb = uniform(DistUInt{4}, 3)
cc=aa-bb
input_names = string.(get_flips(cc) .|> x -> x.global_id)
dump_dot(cc, inames=input_names, filename="ifthenelse-sub.dot")
print("\tNum Nodes if-then-else: ", num_nodes(cc))
