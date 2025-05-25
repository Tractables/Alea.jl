using Test
using CUDD

@testset "BDD" begin
    manager = initialize_cudd()
    x = Cudd_bddNewVar(manager)
    y = Cudd_bddNewVar(manager)
    for v in [x, y]
        @test Cudd_bddIsVar(manager, v) == 1
        index = Cudd_NodeReadIndex(v)
        @test Cudd_bddIsPiVar(manager, index) == 1
        @test Cudd_bddIsPsVar(manager, index) == 0
        @test Cudd_bddIsNsVar(manager, index) == 0
        @test Cudd_IsConstant(v) == 0
        @test Cudd_IsNonConstant(v) == 1
    end
    for (cudd_op, op) in [(Cudd_bddXor, xor), (Cudd_bddOr, |), (Cudd_bddAnd, &)]
        bdd = cudd_op(manager, x, y)
        for values in [[0, 0], [1, 1], [0, 1], [1, 0]]
            expected = op(Bool.(values)...) ? Cudd_ReadOne(manager) : Cudd_ReadLogicZero(manager)
            @test Cudd_Eval(manager, bdd, Cint.(values)) === expected
        end
    end
end

@testset "ADD" begin
    @testset "addind vars" begin
        for i = 1:10
            manager = initialize_cudd()
            rnd = rand(1:100)
            for i = 1:rnd
                add_var(manager)
            end
            @test node_count(manager)-2 == rnd # the constant 0 and 1 nodes are created automatically
        end

        for i = 1:10
            manager = initialize_cudd()
            rnd = rand(i*10:i*10+9)
            indexed_var = add_ith_var(manager, rnd)
            @test read_index(indexed_var) == rnd
        end

        manager = initialize_cudd()
        for i = 1:10
            new_nonconst = add_var(manager)
            @test is_nonconst(new_nonconst) == 1
            new_nonconst = add_level_var(manager, i)
            @test is_nonconst(new_nonconst) == 1
            new_nonconst = add_ith_var(manager, i)
            @test is_nonconst(new_nonconst) == 1
            new_const = add_const(manager, i)
            @test is_const(new_const) == 1
        end
    end

    @testset "outputting files" begin
        manager = initialize_cudd()
        g = add_var(manager)
        @test output_dot(manager, g, "test.dot") == 1
        rm("test.dot")
        @test output_stats(manager, "stats") == 1
        rm("stats")
    end

    @testset "applying constant functions" begin

        manager = initialize_cudd()
        x1, x2 = rand(1:50), rand(51:100)
        f = add_const(manager, x1)
        ref(f)
        g = add_const(manager, x2)
        ref(g)
        res = add_apply(manager, add_plus_c, f, g)
        @test get_value(res) == x1+x2

        res = add_apply(manager, add_times_c, f, g)
        @test get_value(res) == x1*x2

        res = add_apply(manager, add_minus_c, f, g)
        @test get_value(res) == x1-x2

        res = add_apply(manager, add_divide_c, f, g)
        @test get_value(res) == x1/x2

        res = add_apply(manager, add_diff_c, f, g)
        @test get_value(res) == x1

        smaller = add_leq(manager, f, g)
        @test smaller == 1

        bigger = add_leq(manager, g, f)
        @test bigger == 0

        deref(f)
        deref(g)
        recursive_deref(manager, res)
    end

    @testset "addition testing" begin
        manager = initialize_cudd()
        f = add_ith_var(manager, 0)
        ref(f)
        for i = 1:100
            x = add_ith_var(manager, i)
            ref(x)
            tmp = add_apply(manager, add_plus_c, f, x)
            ref(tmp)
            recursive_deref(manager, x)
            recursive_deref(manager, f)
            f = tmp
        end
        assignment = Int32[]
        res = 0
        for i = 0:100
            generated = i%2
            push!(assignment, generated)
            res += generated
        end
        cudd_res = evaluate(manager, f, assignment)
        value = convert(Int, get_value(cudd_res))
        @test value == res

        for i = 1:10
            assignment = Int32[]
            res = 0
            for i = 1:101
                generated = rand(0:1)
                push!(assignment, generated)
                res += generated
            end
            cudd_res = evaluate(manager, f, assignment)
            value = convert(Int, get_value(cudd_res))
            @test value == res
        end
    end

    @testset "multiplication testing" begin
        manager = initialize_cudd()
        f = add_ith_var(manager, 1)
        ref(f)
        for i = 2:101
            x = add_ith_var(manager, i)
            ref(x)
            tmp = add_apply(manager, add_times_c, f, x)
            ref(tmp)
            recursive_deref(manager, x)
            recursive_deref(manager, f)
            f = tmp
        end
        assignment = Int32[]
        res = 0
        for i = 1:101
            generated = i%2
            push!(assignment, generated)
            res *= generated
        end
        cudd_res = evaluate(manager, f, assignment)
        value = convert(Int, get_value(cudd_res))
        @test value == res
    end
end
