using Revise 
using Dice

using Distributions


function convert(R::DistUInt{W}, G::DistUInt{W}, B::DistUInt{W}) where W 
    Co = R - B 
    temp = B + (Co / DistUInt{W}(2))
    Cg = G - temp 
    Y = temp + (Cg / DistUInt{W}(2))

    (Y, Co, Cg)
end

R = uniform(DistUInt{2}, 1)
G = uniform(DistUInt{2}, 1)
B = uniform(DistUInt{2}, 1)

(Y, Co, Cg) = convert(R, G, B)

println("Num Nodes Single Pixel (y): ", num_nodes(Y))
println("Num Nodes Single Pixel (Co): ", num_nodes(Co))
println("Num Nodes Single Pixel (Cg): ", num_nodes(Cg))

# -- Testing a single pixel -- #
R = uniform(DistUInt{4}, 3)
G = uniform(DistUInt{4}, 3)
B = uniform(DistUInt{4}, 3)

(Y, Co, Cg) = convert(R, G, B)

println("Num Nodes Single Pixel (y): ", num_nodes(Y))
println("Num Nodes Single Pixel (Co): ", num_nodes(Co))
println("Num Nodes Single Pixel (Cg): ", num_nodes(Cg))



# -- Mapping a single "image tile" --- #
# A 2×2 sample “image” (each pixel is a 3-tuple of DistUInt)
sample_tile = [
    (uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3))  (uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3));
    (uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3))  (uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3), uniform(DistUInt{4}, 3))
]

function convert_tile(tile::Array{NTuple{3,DistUInt{W}},2}) where W
    h, w = size(tile)
    out = Array{NTuple{3,DistUInt{W}},2}(undef, h, w)
    for i in 1:h, j in 1:w
        R, G, B = tile[i, j]
        out[i, j] = convert(R, G, B)
    end
    return out
end

yco_tile = convert_tile(sample_tile)
println("Converted 2×2 tile to YCoCg:")
for row in eachrow(yco_tile)
    println(row)
end


# -- "Ring/buffer batch conversion" -- #
"""
    to_ycocg_buffer(rgb_buf::Vector{DistUInt}) -> Vector{DistUInt}

Takes rgb_buf of length N (must be divisible by 3), with
  rgb_buf[3k-2..3k] = (R,G,B) for k=1..N/3,
and returns a same-length buffer where each triple is replaced
by the corresponding (Y,Co,Cg).
""" 

function to_ycocg_buffer(rgb_buf::Vector{T}) where {W, T<:Union{DistUInt{W},Uniform{DistUInt{W}}}}
    @assert length(rgb_buf) % 3 == 0 "Buffer length must be a multiple of 3"
    ycob = similar(rgb_buf)      # will be Vector{T} as well
    for i in 1:3:length(rgb_buf)
        R, G, B     = rgb_buf[i], rgb_buf[i+1], rgb_buf[i+2]
        Y, Co, Cg   = convert(R, G, B)
        ycob[i]     = Y
        ycob[i+1]   = Co
        ycob[i+2]   = Cg
    end
    return ycob
end

# Example usage:
raw_stream = [
           DistUInt{4}(2),  DistUInt{4}(7),  DistUInt{4}(1),    # pixel #1
           uniform(DistUInt{4}, 3),  uniform(DistUInt{4}, 3),  uniform(DistUInt{4}, 3)  # pixel #2
       ];
ycocg_stream = to_ycocg_buffer(raw_stream)
println("Raw RGB stream:   ", raw_stream)
println("Converted stream: ", ycocg_stream)

println("Num nodes ycocg stream: ", num_nodes(ycocg_stream))