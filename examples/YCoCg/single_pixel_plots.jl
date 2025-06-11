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


for i in 11:13
    R = uniform(DistUInt{i+1}, i)
    G = uniform(DistUInt{i+1}, i)
    B = uniform(DistUInt{i+1}, i)

    (Y, Co, Cg) = convert(R, G, B)

    trial = @benchmark (num_nodes($Y) + num_nodes($Co) + num_nodes($Cg))
    # compute “pure” compute‐times per sample
    comp_times = trial.times .- trial.gctimes

    tm = mean(comp_times)
    println(tm)

    println("Num nodes:\n\tY: ", num_nodes(Y), "\tCo: ", num_nodes(Co), "\tCg: ", num_nodes(Cg))

    nodes = num_nodes(Y) + num_nodes(Co) + num_nodes(Cg)

    push!(indices, i)
    push!(num_nodes_all, nodes)
    push!(times_ns, tm)
    println("\tNUM NODES Single-Pixel $(i + 1), $i = $nodes")
    println("\tTime: ", tm)
end
println("Time took - ", times_ns)

plot(
    indices, 
    times_ns,
    xlabel = "i (Input Size)",
    ylabel = "Time (ns)",
    title = "Time to run vs Input Size",
    marker = :circle,
    legend = false,
    grid = true
)

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