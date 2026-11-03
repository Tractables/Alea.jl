using Test
using Alea

# The two programs of tddlog's tests/alea/, whose circuits tddlog's tests
# answer against the answers computed by hand.
tiny_pr() = @alea begin
    a = flip(0.3)
    b = flip(0.6)
    x = ifelse(a, DistUInt{3}(1), uniform(DistUInt{3}, 0, 4))
    observe(a | b)
    (a & !b, x + DistUInt{3}(1))
end

tiny_expectation() = @alea begin
    y = uniform(DistInt{4}, -3, 3)
    observe(!prob_equals(y, DistInt{4}(0)))
    y
end

const TINY_PR = """
% tiny_pr.jl: the circuit Alea.jl builds, written by Alea.jl's tddlog backend.
% 4 flips, 9 gates, 1 observations, 9 queries.
0.3::f1.
0.6::f2.
0.5::f3.
0.5::f4.
g1 :- f1, \\+f2.
g2 :- f4, \\+f1.
g3 :- f1.
g3 :- g2.
g4 :- f3, \\+f1.
g5 :- g4, g3.
g6 :- g4, g3.
g7 :- g4.
g7 :- g3.
g8 :- g7, \\+g6.
g9 :- f1.
g9 :- f2.
evidence(g9, true).
q1 :- g1.
query(q1).
q2(0) :- \\+g5, \\+g8, g3.
query(q2(0)).
q2(1) :- \\+g5, \\+g8, \\+g3.
query(q2(1)).
q2(2) :- \\+g5, g8, g3.
query(q2(2)).
q2(3) :- \\+g5, g8, \\+g3.
query(q2(3)).
q2(4) :- g5, \\+g8, g3.
query(q2(4)).
q2(5) :- g5, \\+g8, \\+g3.
query(q2(5)).
q2(6) :- g5, g8, g3.
query(q2(6)).
q2(7) :- g5, g8, \\+g3.
query(q2(7)).
"""

const TINY_EXPECTATION = """
% tiny_expectation.jl: the circuit Alea.jl builds, written by Alea.jl's tddlog backend.
% 4 flips, 15 gates, 1 observations, 4 queries.
0.6666666666666666::f1.
0.5::f2.
0.5::f3.
0.5::f4.
g1 :- f4, \\+f1.
g2 :- f1, f3.
g3 :- g2.
g3 :- g1.
g4 :- f1, f2.
g5 :- g4, g3.
g6 :- g5.
g6 :- \\+f1.
g7 :- f1, g5.
g8 :- f1.
g8 :- g5.
g9 :- g8, \\+g7.
g10 :- g4, g3.
g11 :- g4.
g11 :- g3.
g12 :- g11, \\+g10.
g13 :- g6, \\+g9.
g14 :- g13, \\+g12.
g15 :- g14, g3.
evidence(g15, false).
e1(1) :- \\+g6.
query(e1(1)).
e1(2) :- g9.
query(e1(2)).
e1(3) :- g12.
query(e1(3)).
e1(4) :- \\+g3.
query(e1(4)).
"""

@testset "write_problog" begin
    @test sprint(io -> write_problog(io, tiny_pr(); label = "tiny_pr.jl")) == TINY_PR
    @test sprint(io -> write_problog(io, tiny_expectation(); query = :expectation,
                                     label = "tiny_expectation.jl")) == TINY_EXPECTATION

    # A distribution with evidence; constants are facts or fail.
    a, b = flip(0.25), flip(0.5)
    text = sprint(io -> write_problog(io, (a & b, true, false, DistUInt{2}(1)); evidence = a | b, label = "p"))
    @test occursin("% 2 flips, 2 gates, 1 observations, 4 queries.\n0.25::f1.\n0.5::f2.\n", text)
    @test occursin("evidence(g2, true).\nq1 :- g1.\nquery(q1).\nq2.\nquery(q2).\nq3 :- fail.\nquery(q3).\nq4(0).\nquery(q4(0)).\n", text)

    @test_throws ErrorException write_problog(IOBuffer(), flip(0.5); query = :mean)
    @test_throws ErrorException write_problog(IOBuffer(), uniform(DistUInt{17}))
end

# tddlog's answers, where a tddlog binary is at hand (ENV["TDDLOG"] or on
# the PATH), against Cudd's.
const HAS_TDDLOG = haskey(ENV, "TDDLOG") || !isnothing(Sys.which("tddlog"))

same(d1, d2) = Set(k for (k, p) in d1 if p > 0) == Set(k for (k, p) in d2 if p > 0) &&
    all(isapprox(d1[k], d2[k]; atol = 1e-12) for k in keys(d1))

@testset "Tddlog backend" begin
    if !HAS_TDDLOG
        @info "no tddlog binary (ENV[\"TDDLOG\"] or on the PATH): the Tddlog backend's inference tests are skipped"
        @test_skip false
    else
        algo = Tddlog()

        @test pr(flip(0.78); algo)[true] ≈ 0.78
        @test pr(true; algo)[true] ≈ 1.0

        x = flip(0.2) | flip(0.8)
        y = flip(0.1) | flip(0.3)
        evidence = x | y | flip(0.5)
        for (p, q) in zip(pr(x, y; evidence, algo), pr(x, y; evidence))
            @test same(p, q)
        end

        worlds = pr(JointQuery([x, y]); algo)
        cudd = Dict(pr(JointQuery([x, y])))
        @test sum(w -> w[2], worlds) ≈ 1
        @test length(worlds) == length(cudd)
        @test all(isapprox(p, cudd[w]; atol = 1e-12) for (w, p) in worlds)

        z = uniform(DistUInt{3}, 0, 5) + DistUInt{3}(1)
        @test same(pr(z; algo), pr(z))
        @test same(pr(z; evidence = prob_equals(z, DistUInt{3}(2)) | flip(0.4), algo),
                   pr(z; evidence = prob_equals(z, DistUInt{3}(2)) | flip(0.4)))

        # By hand (tddlog's tests/alea/tiny_pr.jl): q1 = 0.12 / 0.72; x + 1
        # is 1, 3 and 4 with 0.105 / 0.72 each and 2 with 0.405 / 0.72.
        d = pr(tiny_pr(); algo)
        @test same(d, pr(tiny_pr()))
        @test sum(p for ((b, _), p) in d if b) ≈ 0.12 / 0.72
        @test sum(p for ((_, v), p) in d if v == 2) ≈ 0.405 / 0.72
        # By hand: given y != 0, y is uniform on -3, -2, -1, 1, 2.
        @test expectation(tiny_expectation(); algo) ≈ -0.6

        # A probabilistic error stops inference, as with Cudd.
        e = alea() do
            if flip(0.6)
                error("bad branch")
                observe(false)
                true
            else
                false
            end
        end
        @test_throws ProbException pr(e; algo)
        try
            pr(e; algo)
        catch exc
            @test exc isa ProbException
            @test exc.errors[1][1] ≈ 0.6
            @test exc.errors[1][2].msg == "bad branch"
        end
        @test pr(e; ignore_errors = true, algo)[true] ≈ 0

        @test_throws ErrorException pr(flip(0.5); evidence = false, algo)
    end
end
