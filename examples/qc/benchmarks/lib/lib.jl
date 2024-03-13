using Dice
using Dates
using Random

DistNat = DistUInt32

struct RunState
    var_vals::Valuation
    adnodes_of_interest::Dict{String,ADNode}
    io::IO
    out_dir::String
    rng::AbstractRNG
end

include("util.jl")
include("stlc/dist.jl")
include("stlc/generator.jl")
include("stlc/to_coq.jl")
include("bst/dist.jl")
include("bst/generator.jl")
include("rbt/dist.jl")
include("rbt/generator.jl")
include("rbt/to_coq.jl")
