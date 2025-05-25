export add_find_max, add_find_min, add_find_ith

function add_find_max(mgr::Ptr{Manager}, f::Ptr{Node})
    result = Cudd_addFindMax(mgr, f)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end

function add_find_min(mgr::Ptr{Manager}, f::Ptr{Node})
    result = Cudd_addFindMin(mgr, f)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end

function add_find_ith(mgr::Ptr{Manager}, f::Ptr{Node}, i::Int)
    result = Cudd_addIthBit(mgr, f, i)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end
