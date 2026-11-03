export Tddlog, write_problog

##################################
# tddlog backend
##################################

# Exact inference by tddlog (https://github.com/Tractables/tddlog), which
# compiles a ProbLog program bottom-up into tree decision diagrams.
#
# The circuit Alea builds for a program, a DAG of flips, &, | and !, is
# written as a ProbLog program: a flip is a probabilistic fact `P::fN.` (the
# N-th flip of the circuit in the order Alea created them, so that the names
# do not depend on what else the process built before), an & a rule, a | two
# rules, a ! a negated literal, and every observation `evidence(...)`. The
# rules come in a depth-first post-order from the queries and then the
# observations, every gate after the gates it reads.
#
# The writer is tddlog's scripts/alea2problog.jl (Apache License 2.0), moved
# here.

"""
    Tddlog(; command = default_tddlog_command())

Exact inference by tddlog: `pr(x; algo = Tddlog())` writes the circuit of
the queries and the evidence as a ProbLog program (as
[`write_problog`](@ref) does), runs `command` on it and reads its answers.
`command` is a `Cmd`, by default the command in `ENV["TDDLOG"]` or `tddlog`
on the PATH. A query asks for the worlds of its bits, at most 16 bits that
are not constant.
"""
struct Tddlog <: InferAlgo
    command::Cmd
end

Tddlog(; command::Cmd = default_tddlog_command()) = Tddlog(command)

"The tddlog command: `ENV[\"TDDLOG\"]`, split as a shell splits it, or `tddlog` on the PATH."
function default_tddlog_command()
    haskey(ENV, "TDDLOG") && return Cmd(Base.shell_split(ENV["TDDLOG"]))
    exe = Sys.which("tddlog")
    isnothing(exe) && error("no tddlog: put it on the PATH, set ENV[\"TDDLOG\"] or pass Tddlog(command = `...`)")
    `$exe`
end

# The worlds of a query are asked one atom each; past this many bits that
# are not constant, a query is refused.
const MAX_WORLD_BITS = 16

# The nodes under `roots`, every node after its children; iterative, as a
# circuit can be as deep as a loop is long.
function problog_nodes(roots)
    order = Dist{Bool}[]
    seen = IdDict{Dist{Bool}, Bool}()
    for root in roots
        root isa Dist{Bool} || continue
        stack = Tuple{Dist{Bool}, Bool}[(root, false)]
        while !isempty(stack)
            node, expanded = pop!(stack)
            if expanded
                push!(order, node)
                continue
            end
            haskey(seen, node) && continue
            seen[node] = true
            push!(stack, (node, true))
            for child in children(node)
                haskey(seen, child) || push!(stack, (child, false))
            end
        end
    end
    order
end

# The flips under `roots`, numbered from 1 in the order Alea created them.
function problog_flip_numbers(roots)
    fs = sort([n for n in problog_nodes(roots) if n isa Flip]; by = f -> f.global_id)
    IdDict{Dist{Bool}, Int}(f => i for (i, f) in enumerate(fs))
end

# A circuit's nodes in order, every node after its children, and their
# atoms (`problog_circuit`).
struct ProbLogCircuit
    order::Vector{Dist{Bool}}
    names::IdDict{Dist{Bool}, String}
end

"""
The circuit under some roots, its nodes in order, every node after its
children, and their atoms: a flip's `fN` (its number in `flipno`), a gate's
`gK` (the K-th & or | in order); a negation has no atom of its own.
"""
function problog_circuit(roots, flipno = problog_flip_numbers(roots))
    order = problog_nodes(roots)
    names = IdDict{Dist{Bool}, String}()
    k = 0
    for n in order
        if n isa Flip
            names[n] = "f$(flipno[n])"
        elseif !(n isa DistNot)
            k += 1
            names[n] = "g$k"
        end
    end
    ProbLogCircuit(order, names)
end

circuit_flips(c::ProbLogCircuit) = sort([n for n in c.order if n isa Flip]; by = f -> f.global_id)
circuit_gates(c::ProbLogCircuit) = [n for n in c.order if n isa DistAnd || n isa DistOr]

# The literal of a node, negated where `neg`: its atom, or a negation's
# operand's, and whether it is negated.
function circuit_literal(c::ProbLogCircuit, n::Dist{Bool}, neg)
    while n isa DistNot
        n, neg = n.x, !neg
    end
    (c.names[n], neg)
end

# A flip's probability as the program writes it.
function problog_probability(f::Flip)
    f.prob isa Real && !isnan(f.prob) ||
        error("the flip $f has no probability; the tddlog backend needs a number for each flip")
    repr(Float64(f.prob))
end

# The ProbLog program of a circuit, to `io`: `atoms` the queries, each
# (atom, conjunction of (node, polarity)), the conjunction empty for an atom
# that is true and `nothing` for one that is false; `observations` the
# Booleans observed true; `label` names the program in its first line.
function write_circuit(io::IO, atoms, observations, label)
    roots = Any[n for (_, conj) in atoms if conj !== nothing for (n, _) in conj]
    append!(roots, observations)
    c = problog_circuit(roots)
    lit(n, pos = true) = begin
        name, neg = circuit_literal(c, n, !pos)
        neg ? "\\+$name" : name
    end
    println(io, "% $label: the circuit Alea.jl builds, written by Alea.jl's tddlog backend.")
    fs, gs = circuit_flips(c), circuit_gates(c)
    println(io, "% $(length(fs)) flips, $(length(gs)) gates, $(length(observations)) observations, $(length(atoms)) queries.")
    for f in fs
        println(io, problog_probability(f), "::", c.names[f], ".")
    end
    for g in gs
        if g isa DistAnd
            println(io, c.names[g], " :- ", lit(g.x), ", ", lit(g.y), ".")
        else
            println(io, c.names[g], " :- ", lit(g.x), ".")
            println(io, c.names[g], " :- ", lit(g.y), ".")
        end
    end
    # an impossible observation: evidence on an atom defined false, which
    # ProbLog and tddlog find inconsistent, written once
    impossible = false
    for o in observations
        if o isa Bool
            if !o && !impossible
                println(io, "false_observation :- fail.")
                println(io, "evidence(false_observation, true).")
                impossible = true
            end
            continue
        end
        name, neg = circuit_literal(c, o, false)
        println(io, "evidence($name, $(neg ? "false" : "true")).")
    end
    for (atom, conj) in atoms
        if conj === nothing
            println(io, atom, " :- fail.")
        elseif isempty(conj)
            println(io, atom, ".")
        else
            println(io, atom, " :- ", join([lit(n, pos) for (n, pos) in conj], ", "), ".")
        end
        println(io, "query(", atom, ").")
    end
end

# The atoms of the worlds of `bits`, the most significant first: `$(atom)(U)`
# for U = sum_i b_i 2^(n-i) in 0 .. 2^n - 1, the conjunction of its bits'
# literals; `atom` alone, true, for no bits.
function world_atoms(atom, bits)
    n = length(bits)
    n <= MAX_WORLD_BITS ||
        error("$atom has $n bits that are not constant; at most $MAX_WORLD_BITS are queried as worlds")
    n == 0 && return Any[(atom, [])]
    Any[("$atom($u)", [(bits[i], (u >> (n - i)) & 1 == 1) for i in 1:n]) for u in 0:(2^n - 1)]
end

##################################
# Writing a program's circuit
##################################

# The components of a program's value.
problog_components(x::Tuple) = reduce(vcat, map(problog_components, x); init = Any[])
problog_components(x) = Any[x]

# A number's bits, the most significant first, constants included.
problog_bits(x::DistUInt) = x.bits
problog_bits(x::DistInt) = x.number.bits
problog_bits(x::DistFix) = x.mantissa.number.bits
problog_bits(x) = error("write_problog queries Booleans and numbers (DistUInt, DistInt, DistFix), not $(typeof(x))")

isbool(x) = x isa Dist{Bool} || x isa Bool

# The bits of a number that are not constant, each once.
world_bits(x) = unique(Dist{Bool}[b for b in problog_bits(x) if b isa Dist{Bool}])

# The atoms of the components of a program's value under `query`.
function component_atoms(comps, query)
    query in (:pr, :expectation) || error("query must be :pr or :expectation, not $query")
    atoms = Any[]
    for (k, c) in enumerate(comps)
        if isbool(c)
            push!(atoms, ("q$k", c isa Bool ? (c ? [] : nothing) : [(c, true)]))
        elseif query == :pr
            bits = world_bits(c)
            length(bits) <= MAX_WORLD_BITS ||
                error("component $k has $(length(bits)) bits that are not constant; at most $MAX_WORLD_BITS are queried as worlds")
            append!(atoms, isempty(bits) ? Any[("q$k(0)", [])] : world_atoms("q$k", bits))
        else
            seen = Set{Dist{Bool}}()
            for (j, b) in enumerate(problog_bits(c))
                (b isa Dist{Bool} && !(b in seen)) || continue
                push!(seen, b)
                push!(atoms, ("e$k($j)", [(b, true)]))
            end
        end
    end
    atoms
end

"""
    write_problog(io::IO, x; query = :pr, label = "an Alea.jl program")
    write_problog(io::IO, x; query = :pr, evidence = true, label = "an Alea.jl program")

Write the Boolean circuit Alea builds for `x` as a ProbLog program that
tddlog reads, without inference. `x` is what an `@alea` block returns, whose
observations are the evidence, or a distribution, with `evidence` observed:
a Boolean, a number (`DistUInt`, `DistInt`, `DistFix`) or a tuple of them.
Each component K of its value is queried on its own, as `pr(c1, c2, ...)`
answers them (the joint distribution of a returned tuple is not asked):

- a Boolean: `qK`, its probability of being true;
- under `query = :pr`, a number whose bits that are not constant are
  b_1 ... b_n (at most 16): `qK(U)` for every U = sum_i b_i 2^(n-i) in
  0 .. 2^n - 1, the probability of that world of its bits (`frombits` gives
  the value a world names);
- under `query = :expectation`, a number: `eK(I)`, the probability that its
  I-th bit is true, for each bit I that is not constant. The expectation is
  linear in these, as `expectation` computes it: for W bits, the sum of
  eK(I) 2^(W-I), less eK(1) 2^W for a signed number (`DistInt`, `DistFix`),
  and divided by 2^F for a `DistFix{W, F}`.

The probabilistic errors of an `@alea` block are left out of the circuit:
`pr` stops where an error has a positive probability, and where none has,
the circuit's answers are `pr`'s. `label` names the program in the first
line.
"""
function write_problog(io::IO, x::MetaDist; query::Symbol = :pr, label = "an Alea.jl program")
    comps = problog_components(returnvalue(x))
    write_circuit(io, component_atoms(comps, query), observations(x), label)
end

function write_problog(io::IO, x; query::Symbol = :pr, evidence::AnyBool = true, label = "an Alea.jl program")
    comps = problog_components(x)
    write_circuit(io, component_atoms(comps, query), evidence === true ? AnyBool[] : AnyBool[evidence], label)
end

##################################
# Inference
##################################

# tddlog's answers for the queries `atoms` (as `write_circuit` takes them)
# given `observations`: a Dict of each atom to its probability, or `nothing`
# where the evidence is inconsistent.
function run_tddlog(algo::Tddlog, atoms, observations)
    path, io = mktemp()
    try
        write_circuit(io, atoms, observations, "a query of Alea.jl")
        close(io)
        out = read(`$(algo.command) --precision 17 $path`, String)
        occursin(r"^evidence is inconsistent"m, out) && return nothing
        answers = Dict{String, Float64}()
        for line in eachline(IOBuffer(out))
            m = match(r"^(\S+):\t(\S+)$", line)
            isnothing(m) || (answers[m[1]] = parse(Float64, m[2]))
        end
        for (atom, _) in atoms
            haskey(answers, atom) || error("tddlog gave no answer for $atom")
        end
        answers
    finally
        close(io)
        rm(path; force = true)
    end
end

function pr_impl(algo::Tddlog, evidence, queries::Vector{JointQuery}, errors, dots)
    isempty(dots) || error("the tddlog backend writes no BDDs: dots need the Cudd backend")

    # the probability of every error, without the evidence, as Cudd computes it
    if !isempty(errors)
        atoms = Any[("err$j", cond isa Bool ? (cond ? [] : nothing) : [(cond, true)])
                    for (j, (cond, _)) in enumerate(errors)]
        answers = run_tddlog(algo, atoms, AnyBool[])
        prob_errors = ProbError[(answers["err$j"], err) for (j, (_, err)) in enumerate(errors)
                                if answers["err$j"] > 0]
        isempty(prob_errors) || throw(ProbException(prob_errors))
    end

    # the worlds of every query given the evidence
    atoms = reduce(vcat, (world_atoms("q$k", q.bits) for (k, q) in enumerate(queries)); init = Any[])
    answers = run_tddlog(algo, atoms, evidence === true ? AnyBool[] : AnyBool[evidence])
    isnothing(answers) && error("Cannot find any possible worlds: the evidence has probability zero")
    map(enumerate(queries)) do (k, q)
        n = length(q.bits)
        n == 0 && return [(Dict{Dist{Bool}, Bool}(), answers["q$k"])]
        worlds = Tuple{Dict{Dist{Bool}, Bool}, Float64}[]
        for u in 0:(2^n - 1)
            p = answers["q$k($u)"]
            p > 0 && push!(worlds, (Dict{Dist{Bool}, Bool}(q.bits[i] => (u >> (n - i)) & 1 == 1 for i in 1:n), p))
        end
        worlds
    end
end
