using Revise
using Dice
using Dates
using Plots
using BenchmarkTools
using Distributions

num_nodes_all = Int[] 
indices = Int[] 
times_ns = Float64[]


function convert(R::DistUInt{W}, G::DistUInt{W}, B::DistUInt{W}) where W 
    Co = R - B 
    temp = B + (Co / DistUInt{W}(2))
    Cg = G - temp 
    Y = temp + (Cg / DistUInt{W}(2))

    (Y, Co, Cg)
end

function convert_tile(tile::Array{NTuple{3,DistUInt{W}},2}) where W
    h, w = size(tile)
    out = Array{NTuple{3,DistUInt{W}},2}(undef, h, w)
    for i in 1:h, j in 1:w
        R, G, B = tile[i, j]
        out[i, j] = convert(R, G, B)
    end
    return out
end

for i in 1:2
    sample_tile = [
        (uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3))  (uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3));
        (uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3))  (uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3))
    ]

    yco_tile = convert_tile(sample_tile)
    nodes = 0
    for row in eachrow(yco_tile)
        nodes += num_nodes(row) # 'row' is a typle of arrays of distUInts?
    end
    println("Num nodes for iteration ", i, " = ", nodes)

    # trial = @benchmark (num_nodes($Y) + num_nodes($Co) + num_nodes($Cg))
    # # compute “pure” compute‐times per sample
    # comp_times = trial.times .- trial.gctimes

    # tm = mean(comp_times)
    # println(tm)

    push!(indices, i)
    push!(num_nodes_all, nodes)
    # push!(times_ns, tm)
    println("\tNUM NODES Small Tile $(i + 1), $i = $nodes")
    # println("\tTime: ", tm)
end
# println("Time took - ", times_ns)

# plot(
#     indices, 
#     times_ns,
#     xlabel = "i (Input Size)",
#     ylabel = "Time (ns)",
#     title = "Time to run vs Input Size",
#     marker = :circle,
#     legend = false,
#     grid = true
# )

println("Num Nodes: ", num_nodes_all)

plot(
    indices, 
    num_nodes_all,
    xlabel = "i (Input Size)",
    ylabel = "num_nodes",
    title = "num_nodes vs Input Size",
    marker = :circle,
    legend = false,
    grid = true
)