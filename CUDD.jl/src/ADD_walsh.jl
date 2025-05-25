export add_walsh, add_residue

function add_walsh(mgr::Ptr{Manager}, f_pp::Ptr{Ptr{Node}}, g_pp::Ptr{Ptr{Node}}, n::Int)
    result = Cudd_addWalsh(mgr, f_pp, g_pp, n)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end

function add_residue(mgr::Ptr{Manager}, n::Int, m::Int, options::Int, top::Int)
    result = Cudd_addResidue(mgr, n, m, options, top)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end
