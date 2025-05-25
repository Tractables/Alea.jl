export add_ite, add_ite_const, add_eval_const
export add_leq
export add_comp

function add_ite(mgr::Ptr{Manager}, f::Ptr{Node}, g::Ptr{Node}, h::Ptr{Node})
    result = Cudd_addIte(mgr, f, g, h)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end

function add_ite_const(mgr::Ptr{Manager}, f::Ptr{Node}, g::Ptr{Node}, h::Ptr{Node})
    result = Cudd_addIteConstant(mgr, f, g, h)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end

function add_eval_const(mgr::Ptr{Manager}, f::Ptr{Node}, g::Ptr{Node})
    result = Cudd_addEvalConst(mgr, f, g)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end

function add_leq(mgr::Ptr{Manager}, f::Ptr{Node}, g::Ptr{Node})
    result = Cudd_addLeq(mgr, f, g)
    return result
end

function add_comp(mgr::Ptr{Manager}, f::Ptr{Node})
    result = Cudd_addCmpl(mgr, f)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end
