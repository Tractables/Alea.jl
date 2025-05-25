export Manager, Node
export CUDD_UNIQUE_SLOTS, CUDD_CACHE_SLOTS
export initialize_cudd
export add_var, add_ith_var, add_level_var, add_const, add_constraint
export ref, deref, recursive_deref
export add_constraint, add_restrict, evaluate
export get_value, is_const, is_nonconst, read_index, node_count
export output_dot, output_stats

const Manager = DdManager
const Node = DdNode
mutable struct FILE end

function initialize_cudd()
    dd_manager = Cudd_Init(0, 0, CUDD_UNIQUE_SLOTS, CUDD_CACHE_SLOTS, 0)
    if dd_manager == C_NULL # Could not allocate memory
        throw(OutOfMemoryError())
    end
    return dd_manager
end

function add_var(mgr::Ptr{Manager})
    new_var = Cudd_addNewVar(mgr)
    if new_var == C_NULL # Could not allocate memory
        throw(OutOfMemoryError())
    end
    return new_var
end

function add_ith_var(mgr::Ptr{Manager}, i::Int)
    new_var = Cudd_addIthVar(mgr, i)
    if new_var == C_NULL # Could not allocate memory
        throw(OutOfMemoryError())
    end
    return new_var
end

function add_level_var(mgr::Ptr{Manager}, level::Int)
    new_var = Cudd_addNewVarAtLevel(mgr, level)
    if new_var == C_NULL
        throw(OutOfMemoryError())
    end
    return new_var
end

function add_const(mgr::Ptr{Manager}, c::Real)
    const_node = Cudd_addConst(mgr, c)
    if const_node == C_NULL
        throw(OutOfMemoryError())
    end
    return const_node
end

function add_constraint(mgr::Ptr{Manager}, f::Ptr{Node}, c::Ptr{Node})
    res = Cudd_addConstrain(mgr, f, c)
    if res == C_NULL
        throw(OutOfMemoryError())
    end
    return res
end

function add_restrict(mgr::Ptr{Manager}, f::Ptr{Node}, c::Ptr{Node})
    res = Cudd_addRestrict(mgr, f, c)
    if res == C_NULL
        throw(OutOfMemoryError())
    end
    return res
end

# WARNING: the assignment array starts with the variable indexed 0;
# hence, be sure to create the ith variable from index 0.
function evaluate(mgr::Ptr{Manager}, f::Ptr{Node}, assignment::Array{Cint})
    res = Cudd_Eval(mgr, f, assignment)
    if res == C_NULL
        throw(OutOfMemoryError())
    end
    return res
end

function ref(n::Ptr{Node})
    Cudd_Ref(n)
end

function deref(n::Ptr{Node})
    Cudd_Deref(n)
end

function recursive_deref(table::Ptr{Manager}, n::Ptr{Node})
    Cudd_RecursiveDeref(table, n)
end

function get_value(c::Ptr{Node})
    res = Cudd_V(c)
    if res == C_NULL
        throw(OutOfMemoryError())
    end
    return res
end

function is_const(n::Ptr{Node})
    return Cudd_IsConstant(n)
end

function is_nonconst(n::Ptr{Node})
    return Cudd_IsNonConstant(n)
end

function read_index(n::Ptr{Node})
    return Cudd_NodeReadIndex(n)
end

function node_count(mgr::Ptr{Manager})
    return Cudd_ReadNodeCount(mgr)
end

function output_dot(mgr::Ptr{Manager}, f::Ptr{Node}, filename::String)
    outfile = ccall(:fopen, Ptr{FILE}, (Cstring, Cstring), filename, "w")
    res = Cudd_DumpDot(mgr, 1, Ref(f), C_NULL, C_NULL, outfile)
    ccall(:fclose, Cint, (Ptr{FILE},), outfile)  # here returns 0 suggesting the file is successfully closed
    return res
end

function output_stats(mgr::Ptr{Manager}, filename::String)
    outfile = ccall(:fopen, Ptr{FILE}, (Cstring, Cstring), filename, "w")
    res = Cudd_PrintInfo(mgr, outfile)
    ccall(:fclose, Cint, (Ptr{FILE},), outfile)
    return res
end
