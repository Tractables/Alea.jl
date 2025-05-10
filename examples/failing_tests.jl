using Revise
using Dice 
# using Alea
# using Test

a = uniform_arith(DistUInt{3}, 0, 8)
b = uniform_arith(DistUInt{3}, 0, 8)
c = @dice a/b
# c = @alea a/b
# @test_throws ProbException pr(c)
