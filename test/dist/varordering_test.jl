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


@testset "VarOrder Interleaving - Comparisons" begin

    b = uniform(DistUInt{3}, 2)
    c = uniform(DistUInt{3}, 2)
    d = b < c
    @test num_nodes(d) == 7

    b = uniform(DistUInt{4}, 3)
    c = uniform(DistUInt{4}, 3)
    d = b < c
    @test num_nodes(d) == 10

    b = uniform(DistUInt{5}, 4)
    c = uniform(DistUInt{5}, 4)
    d = b < c
    @test num_nodes(d) == 13

    b = uniform(DistUInt{6}, 5)
    c = uniform(DistUInt{6}, 5)
    d = b < c
    @test num_nodes(d) == 16

    b = uniform(DistUInt{7}, 6)
    c = uniform(DistUInt{7}, 6)
    d = b < c
    @test num_nodes(d) == 19

    b = uniform(DistUInt{8}, 7)
    c = uniform(DistUInt{8}, 7)
    d = b < c
    @test num_nodes(d) == 22

    b = uniform(DistUInt{10}, 9)
    c = uniform(DistUInt{10}, 9)
    d = b < c
    @test num_nodes(d) == 28

    b = uniform(DistUInt{12}, 11)
    c = uniform(DistUInt{12}, 11)
    d = b < c
    @test num_nodes(d) == 34

    b = uniform(DistUInt{16}, 15)
    c = uniform(DistUInt{16}, 15)
    d = b < c
    @test num_nodes(d) == 46

    b = uniform(DistUInt{20}, 19)
    c = uniform(DistUInt{20}, 19)
    d = b < c
    @test num_nodes(d) == 58

    b = uniform(DistUInt{26}, 25)
    c = uniform(DistUInt{26}, 25)
    d = b < c
    @test num_nodes(d) == 76

end