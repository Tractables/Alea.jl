export add_negate, add_round_off

function add_negate(mgr::Ptr{Manager}, f::Ptr{Node})
    result = Cudd_addNegate(mgr, f)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end

function add_round_off(mgr::Ptr{Manager}, f::Ptr{Node}, n::Int)
    result = Cudd_addRoundOff(mgr, f, n)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end
