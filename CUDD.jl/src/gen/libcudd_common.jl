# Automatically generated using Clang.jl


const CUDD_TRUE = 1
const CUDD_FALSE = 0
const CUDD_OUT_OF_MEM = -1
const CUDD_UNIQUE_SLOTS = 256
const CUDD_CACHE_SLOTS = 262144
const CUDD_RESIDUE_DEFAULT = 0
const CUDD_RESIDUE_MSB = 1
const CUDD_RESIDUE_TC = 2

# Skipping MacroDefinition: Cudd_Not ( node ) ( ( DdNode * ) ( ( uintptr_t ) ( node ) ^ ( uintptr_t ) 01 ) )
# Skipping MacroDefinition: Cudd_NotCond ( node , c ) ( ( DdNode * ) ( ( uintptr_t ) ( node ) ^ ( uintptr_t ) ( c ) ) )
# Skipping MacroDefinition: Cudd_Regular ( node ) ( ( DdNode * ) ( ( uintptr_t ) ( node ) & ~ ( uintptr_t ) 01 ) )
# Skipping MacroDefinition: Cudd_Complement ( node ) ( ( DdNode * ) ( ( uintptr_t ) ( node ) | ( uintptr_t ) 01 ) )
# Skipping MacroDefinition: Cudd_IsComplement ( node ) ( ( int ) ( ( uintptr_t ) ( node ) & ( uintptr_t ) 01 ) )
# Skipping MacroDefinition: Cudd_ReadIndex ( dd , index ) ( Cudd_ReadPerm ( dd , index ) )
# Skipping MacroDefinition: Cudd_ForeachCube ( manager , f , gen , cube , value ) for ( ( gen ) = Cudd_FirstCube ( manager , f , & cube , & value ) ; Cudd_IsGenEmpty ( gen ) ? Cudd_GenFree ( gen ) : CUDD_TRUE ; ( void ) Cudd_NextCube ( gen , & cube , & value ) )
# Skipping MacroDefinition: Cudd_ForeachPrime ( manager , l , u , gen , cube ) for ( ( gen ) = Cudd_FirstPrime ( manager , l , u , & cube ) ; Cudd_IsGenEmpty ( gen ) ? Cudd_GenFree ( gen ) : CUDD_TRUE ; ( void ) Cudd_NextPrime ( gen , & cube ) )
# Skipping MacroDefinition: Cudd_ForeachNode ( manager , f , gen , node ) for ( ( gen ) = Cudd_FirstNode ( manager , f , & node ) ; Cudd_IsGenEmpty ( gen ) ? Cudd_GenFree ( gen ) : CUDD_TRUE ; ( void ) Cudd_NextNode ( gen , & node ) )
# Skipping MacroDefinition: Cudd_zddForeachPath ( manager , f , gen , path ) for ( ( gen ) = Cudd_zddFirstPath ( manager , f , & path ) ; Cudd_IsGenEmpty ( gen ) ? Cudd_GenFree ( gen ) : CUDD_TRUE ; ( void ) Cudd_zddNextPath ( gen , & path ) )

@cenum Cudd_ReorderingType::UInt32 begin
    CUDD_REORDER_SAME = 0
    CUDD_REORDER_NONE = 1
    CUDD_REORDER_RANDOM = 2
    CUDD_REORDER_RANDOM_PIVOT = 3
    CUDD_REORDER_SIFT = 4
    CUDD_REORDER_SIFT_CONVERGE = 5
    CUDD_REORDER_SYMM_SIFT = 6
    CUDD_REORDER_SYMM_SIFT_CONV = 7
    CUDD_REORDER_WINDOW2 = 8
    CUDD_REORDER_WINDOW3 = 9
    CUDD_REORDER_WINDOW4 = 10
    CUDD_REORDER_WINDOW2_CONV = 11
    CUDD_REORDER_WINDOW3_CONV = 12
    CUDD_REORDER_WINDOW4_CONV = 13
    CUDD_REORDER_GROUP_SIFT = 14
    CUDD_REORDER_GROUP_SIFT_CONV = 15
    CUDD_REORDER_ANNEALING = 16
    CUDD_REORDER_GENETIC = 17
    CUDD_REORDER_LINEAR = 18
    CUDD_REORDER_LINEAR_CONVERGE = 19
    CUDD_REORDER_LAZY_SIFT = 20
    CUDD_REORDER_EXACT = 21
end

@cenum Cudd_AggregationType::UInt32 begin
    CUDD_NO_CHECK = 0
    CUDD_GROUP_CHECK = 1
    CUDD_GROUP_CHECK2 = 2
    CUDD_GROUP_CHECK3 = 3
    CUDD_GROUP_CHECK4 = 4
    CUDD_GROUP_CHECK5 = 5
    CUDD_GROUP_CHECK6 = 6
    CUDD_GROUP_CHECK7 = 7
    CUDD_GROUP_CHECK8 = 8
    CUDD_GROUP_CHECK9 = 9
end

@cenum Cudd_HookType::UInt32 begin
    CUDD_PRE_GC_HOOK = 0
    CUDD_POST_GC_HOOK = 1
    CUDD_PRE_REORDERING_HOOK = 2
    CUDD_POST_REORDERING_HOOK = 3
end

@cenum Cudd_ErrorType::UInt32 begin
    CUDD_NO_ERROR = 0
    CUDD_MEMORY_OUT = 1
    CUDD_TOO_MANY_NODES = 2
    CUDD_MAX_MEM_EXCEEDED = 3
    CUDD_TIMEOUT_EXPIRED = 4
    CUDD_TERMINATION = 5
    CUDD_INVALID_ARG = 6
    CUDD_INTERNAL_ERROR = 7
end

@cenum Cudd_LazyGroupType::UInt32 begin
    CUDD_LAZY_NONE = 0
    CUDD_LAZY_SOFT_GROUP = 1
    CUDD_LAZY_HARD_GROUP = 2
    CUDD_LAZY_UNGROUP = 3
end

@cenum Cudd_VariableType::UInt32 begin
    CUDD_VAR_PRIMARY_INPUT = 0
    CUDD_VAR_PRESENT_STATE = 1
    CUDD_VAR_NEXT_STATE = 2
end


const CUDD_VALUE_TYPE = Cdouble
const DdNode = Cvoid
const DdNodePtr = Ptr{DdNode}
const DdManager = Cvoid
const DdGen = Cvoid
const DdApaDigit = UInt32
const DdApaNumber = Ptr{DdApaDigit}
const DdConstApaNumber = Ptr{DdApaDigit}
const DdTlcInfo = Cvoid
const DD_HFP = Ptr{Cvoid}
const DD_PRFP = Ptr{Cvoid}
const DD_AOP = Ptr{Cvoid}
const DD_MAOP = Ptr{Cvoid}
const DD_CTFP = Ptr{Cvoid}
const DD_CTFP1 = Ptr{Cvoid}
const DD_OOMFP = Ptr{Cvoid}
const DD_QSFP = Ptr{Cvoid}
const DD_THFP = Ptr{Cvoid}
const DD_TOHFP = Ptr{Cvoid}
