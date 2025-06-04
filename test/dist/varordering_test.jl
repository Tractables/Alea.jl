using Test
using Dice
using Dice: Flip, num_ir_nodes

@testset "VarOrder Interleaving - Addition" begin

    d = uniform(DistUInt{3}, 2)
    e = uniform(DistUInt{3}, 2)
    f = d+e
    @test num_nodes(f) == 13

    a = uniform(DistUInt{4}, 3)
    b = uniform(DistUInt{4}, 3)
    c = a+b
    @test num_nodes(c) == 22

    g = uniform(DistUInt{5}, 4)
    h = uniform(DistUInt{5}, 4)
    i = g+h
    @test num_nodes(i) == 31

    g = uniform(DistUInt{8}, 7)
    h = uniform(DistUInt{8}, 7)
    i = g+h
    @test num_nodes(i) == 58

    g = uniform(DistUInt{10}, 9)
    h = uniform(DistUInt{10}, 9)
    i = g+h
    @test num_nodes(i) == 76

    g = uniform(DistUInt{15}, 14)
    h = uniform(DistUInt{15}, 14)
    i = g+h
    @test num_nodes(i) == 121

    d = uniform(DistUInt{20}, 19)
    e = uniform(DistUInt{20}, 19)
    f = d+e
    @test num_nodes(f) == 166

    d = uniform(DistUInt{31}, 30)
    e = uniform(DistUInt{31}, 30)
    f = d+e
    @test num_nodes(f) == 265

end

@testset "VarOrder Interleaving - Subtraction" begin

    d = uniform(DistUInt{3}, 2)
    e = uniform(DistUInt{3}, 2)
    f = d-e
    @test num_nodes(f) == 13

    a = uniform(DistUInt{4}, 3)
    b = uniform(DistUInt{4}, 3)
    c = a-b
    @test num_nodes(c) == 22

    g = uniform(DistUInt{5}, 4)
    h = uniform(DistUInt{5}, 4)
    i = g-h
    @test num_nodes(i) == 31

    g = uniform(DistUInt{8}, 7)
    h = uniform(DistUInt{8}, 7)
    i = g-h
    @test num_nodes(i) == 58

    g = uniform(DistUInt{10}, 9)
    h = uniform(DistUInt{10}, 9)
    i = g-h
    @test num_nodes(i) == 76

    g = uniform(DistUInt{15}, 14)
    h = uniform(DistUInt{15}, 14)
    i = g-h
    @test num_nodes(i) == 121

    d = uniform(DistUInt{20}, 19)
    e = uniform(DistUInt{20}, 19)
    f = d-e
    @test num_nodes(f) == 166

    d = uniform(DistUInt{31}, 30)
    e = uniform(DistUInt{31}, 30)
    f = d-e
    @test num_nodes(f) == 265

end

@testset "VarOrder Interleaving - If-Then-Else" begin

    a = DistUInt( [flip(0.0), flip(0.2), flip(0.5)])
    b = DistUInt( [flip(0.0), flip(0.5), ifelse(flip(0.9), flip(0.3), flip(0.7))])
    c = a + b
    @test num_nodes(c) == 17

    e = uniform(DistUInt{8}, 7)
    f = DistUInt( [flip(0.0), flip(0.5), ifelse(flip(0.9), flip(0.3), flip(0.7)), flip(0.5), flip(0.5), flip(0.5), flip(0.5), flip(0.5)])
    g = e+f
    @test num_nodes(g) == 70

end

@testset "VarOrder Interleaving - Interdependent" begin

    a = flip(0.5)
    b = DistUInt( [flip(0.0), a, flip(0.7), flip(0.8), flip(0.6)] )
    c = DistUInt( [flip(0.0), flip(0.3), flip(0.4), flip(0.2), a] )
    sum = b+c
    @test num_nodes(sum) == 45

    a = flip(0.5)
    b = DistUInt( [flip(0.0), flip(0.7), flip(0.8), flip(0.6), a] )
    c = DistUInt( [flip(0.0), a, flip(0.3), flip(0.4), flip(0.2)] )
    sum = b+c
    @test num_nodes(sum) == 45

    d = flip(0.5)
    e = DistUInt( [flip(0.0), d, flip(0.5)])
    f = DistUInt( [flip(0.0), flip(0.5), ifelse(d, flip(0.3), flip(0.7))])
    g = e+f
    @test num_nodes(g) == 19

end