using Revise
using Dice
using Dates
using Plots
using BenchmarkTools

num_nodes_all = Int[] 
indices = Int[] 
times_ns = Float64[]


for i in 1:30       # too long past 23 for ordering by global_id
    a = uniform(DistUInt{i + 1}, i)
    b = uniform(DistUInt{i + 1}, i)

    c = a + b
    trial = @benchmark num_nodes($c)
    # compute “pure” compute‐times per sample
    comp_times = trial.times .- trial.gctimes

    tm = mean(comp_times)
    println(tm)
    nodes = num_nodes(c)

    push!(indices, i)
    push!(num_nodes_all, nodes)
    push!(times_ns, tm)
    println("\tNUM NODES ADD $(i + 1), $i = $nodes")
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