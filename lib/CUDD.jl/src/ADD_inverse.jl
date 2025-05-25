export add_scalar_inverse

function add_scalar_inverse(mgr::Ptr{Manager}, f::Ptr{Node}, epsilon::Ptr{Node})
    result = Cudd_addScalarInverse(mgr, f, epsilon)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end
