export add_apply
export add_plus_c, add_minus_c, add_times_c, add_divide_c, add_diff_c
export add_threshold_c, add_setnz_c
export add_minimum_c, add_maximum_c, add_one_zero_maximum_c
export add_or_c, add_nand_c, add_nor_c, add_xor_c, add_xnor_c
export add_log_c

function add_apply(mgr::Ptr{Manager}, op::Ref, f::Ptr{Node}, g::Ptr{Node})
    res = ccall((:Cudd_addApply, libcudd),
        Ptr{Node}, (Ptr{Manager}, Ptr{Cvoid}, Ptr{Node}, Ptr{Node}), mgr, op[], f, g)
    if res == C_NULL # Fails to compute a result
        throw(OutOfMemoryError())
    end
    return res
end

add_apply_func_names = [(:add_plus, :Cudd_addPlus),
                        (:add_minus, :Cudd_addMinus),
                        (:add_times, :Cudd_addTimes),
                        (:add_divide, :Cudd_addDivide),
                        (:add_diff, :Cudd_addDiff),
                        (:add_threshold, :Cudd_addThreshold),
                        (:add_setNZ, :Cudd_addSetNZ),
                        (:add_minimum, :Cudd_addMinimum),
                        (:add_maximum, :Cudd_addMaximum),
                        (:add_one_zero_maximum, :Cudd_addOneZeroMaximum),
                        (:add_agreement, :Cudd_addAgreement),
                        (:add_or, :Cudd_addOr),
                        (:add_nand, :Cudd_addNand),
                        (:add_nor, :Cudd_addNor),
                        (:add_xor, :Cudd_addXor),
                        (:add_xnor, :Cudd_addXnor),
                        (:add_log, :Cudd_addLog)]

add_apply_func_ptr_refs = Dict{Function, Ref{Base.CFunction}}()

for (name, Cudd_name) in add_apply_func_names

    # define new names without the `Cudd_`
    @eval $name(mgr::Ptr{Manager}, f_pp::Ptr{Ptr{Node}}, g_pp::Ptr{Ptr{Node}}) =
                $Cudd_name(mgr, f_pp, g_pp)

    # `func` is the newly created function from above
    func = getproperty(CUDD, name)

    # These Refs must get filled in __init__(). They have names like `add_plus_c`, etc.
    # They are in a Dict only for easier access in __init__, their binding is also global.
    add_apply_func_ptr_refs[func] = @eval const $(Symbol(name, "_c")) = Ref{Base.CFunction}()
end

function __init__()
    for (func, ref) in add_apply_func_ptr_refs
        # ref[] = @cfunction($func, Ptr{Node}, (Ptr{Manager}, Ptr{Ptr{Node}}, Ptr{Ptr{Node}}))
    end
end
