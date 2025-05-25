export add_exist_abstract, add_univ_abstract, add_or_abstract

function add_exist_abstract(mgr::Ptr{Manager}, f::Ptr{Node}, cube::Ptr{Node})
    result = Cudd_addExistAbstract(mgr, f, cube)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end

function add_univ_abstract(mgr::Ptr{Manager}, f::Ptr{Node}, cube::Ptr{Node})
    result = Cudd_addUnivAbstract(mgr, f, cube)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end

function add_or_abstract(mgr::Ptr{Manager}, f::Ptr{Node}, cube::Ptr{Node})
    result = Cudd_addOrAbstract(mgr, f, cube)
    if result == C_NULL
        throw(OutOfMemoryError())
    end
    return result
end
