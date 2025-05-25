# Julia wrapper for header: cudd.h
# Automatically generated using Clang.jl


function Cudd_addNewVar(dd)
    ccall((:Cudd_addNewVar, libcudd), Ptr{DdNode}, (Ptr{DdManager},), dd)
end

function Cudd_addNewVarAtLevel(dd, level)
    ccall((:Cudd_addNewVarAtLevel, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint), dd, level)
end

function Cudd_bddNewVar(dd)
    ccall((:Cudd_bddNewVar, libcudd), Ptr{DdNode}, (Ptr{DdManager},), dd)
end

function Cudd_bddNewVarAtLevel(dd, level)
    ccall((:Cudd_bddNewVarAtLevel, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint), dd, level)
end

function Cudd_bddIsVar(dd, f)
    ccall((:Cudd_bddIsVar, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_addIthVar(dd, i)
    ccall((:Cudd_addIthVar, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint), dd, i)
end

function Cudd_bddIthVar(dd, i)
    ccall((:Cudd_bddIthVar, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint), dd, i)
end

function Cudd_zddIthVar(dd, i)
    ccall((:Cudd_zddIthVar, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint), dd, i)
end

function Cudd_zddVarsFromBddVars(dd, multiplicity)
    ccall((:Cudd_zddVarsFromBddVars, libcudd), Cint, (Ptr{DdManager}, Cint), dd, multiplicity)
end

function Cudd_ReadMaxIndex()
    ccall((:Cudd_ReadMaxIndex, libcudd), UInt32, ())
end

function Cudd_addConst(dd, c)
    ccall((:Cudd_addConst, libcudd), Ptr{DdNode}, (Ptr{DdManager}, CUDD_VALUE_TYPE), dd, c)
end

function Cudd_IsConstant(node)
    ccall((:Cudd_IsConstant, libcudd), Cint, (Ptr{DdNode},), node)
end

function Cudd_IsNonConstant(f)
    ccall((:Cudd_IsNonConstant, libcudd), Cint, (Ptr{DdNode},), f)
end

function Cudd_T(node)
    ccall((:Cudd_T, libcudd), Ptr{DdNode}, (Ptr{DdNode},), node)
end

function Cudd_E(node)
    ccall((:Cudd_E, libcudd), Ptr{DdNode}, (Ptr{DdNode},), node)
end

function Cudd_V(node)
    ccall((:Cudd_V, libcudd), CUDD_VALUE_TYPE, (Ptr{DdNode},), node)
end

function Cudd_ReadStartTime(unique)
    ccall((:Cudd_ReadStartTime, libcudd), Culong, (Ptr{DdManager},), unique)
end

function Cudd_ReadElapsedTime(unique)
    ccall((:Cudd_ReadElapsedTime, libcudd), Culong, (Ptr{DdManager},), unique)
end

function Cudd_SetStartTime(unique, st)
    ccall((:Cudd_SetStartTime, libcudd), Cvoid, (Ptr{DdManager}, Culong), unique, st)
end

function Cudd_ResetStartTime(unique)
    ccall((:Cudd_ResetStartTime, libcudd), Cvoid, (Ptr{DdManager},), unique)
end

function Cudd_ReadTimeLimit(unique)
    ccall((:Cudd_ReadTimeLimit, libcudd), Culong, (Ptr{DdManager},), unique)
end

function Cudd_SetTimeLimit(unique, tl)
    ccall((:Cudd_SetTimeLimit, libcudd), Culong, (Ptr{DdManager}, Culong), unique, tl)
end

function Cudd_UpdateTimeLimit(unique)
    ccall((:Cudd_UpdateTimeLimit, libcudd), Cvoid, (Ptr{DdManager},), unique)
end

function Cudd_IncreaseTimeLimit(unique, increase)
    ccall((:Cudd_IncreaseTimeLimit, libcudd), Cvoid, (Ptr{DdManager}, Culong), unique, increase)
end

function Cudd_UnsetTimeLimit(unique)
    ccall((:Cudd_UnsetTimeLimit, libcudd), Cvoid, (Ptr{DdManager},), unique)
end

function Cudd_TimeLimited(unique)
    ccall((:Cudd_TimeLimited, libcudd), Cint, (Ptr{DdManager},), unique)
end

function Cudd_RegisterTerminationCallback(unique, callback, callback_arg)
    ccall((:Cudd_RegisterTerminationCallback, libcudd), Cvoid, (Ptr{DdManager}, DD_THFP, Ptr{Cvoid}), unique, callback, callback_arg)
end

function Cudd_UnregisterTerminationCallback(unique)
    ccall((:Cudd_UnregisterTerminationCallback, libcudd), Cvoid, (Ptr{DdManager},), unique)
end

function Cudd_RegisterOutOfMemoryCallback(unique, callback)
    ccall((:Cudd_RegisterOutOfMemoryCallback, libcudd), DD_OOMFP, (Ptr{DdManager}, DD_OOMFP), unique, callback)
end

function Cudd_UnregisterOutOfMemoryCallback(unique)
    ccall((:Cudd_UnregisterOutOfMemoryCallback, libcudd), Cvoid, (Ptr{DdManager},), unique)
end

function Cudd_RegisterTimeoutHandler(unique, handler, arg)
    ccall((:Cudd_RegisterTimeoutHandler, libcudd), Cvoid, (Ptr{DdManager}, DD_TOHFP, Ptr{Cvoid}), unique, handler, arg)
end

function Cudd_ReadTimeoutHandler(unique, argp)
    ccall((:Cudd_ReadTimeoutHandler, libcudd), DD_TOHFP, (Ptr{DdManager}, Ptr{Ptr{Cvoid}}), unique, argp)
end

function Cudd_AutodynEnable(unique, method)
    ccall((:Cudd_AutodynEnable, libcudd), Cvoid, (Ptr{DdManager}, Cudd_ReorderingType), unique, method)
end

function Cudd_AutodynDisable(unique)
    ccall((:Cudd_AutodynDisable, libcudd), Cvoid, (Ptr{DdManager},), unique)
end

function Cudd_ReorderingStatus(unique, method)
    ccall((:Cudd_ReorderingStatus, libcudd), Cint, (Ptr{DdManager}, Ptr{Cudd_ReorderingType}), unique, method)
end

function Cudd_AutodynEnableZdd(unique, method)
    ccall((:Cudd_AutodynEnableZdd, libcudd), Cvoid, (Ptr{DdManager}, Cudd_ReorderingType), unique, method)
end

function Cudd_AutodynDisableZdd(unique)
    ccall((:Cudd_AutodynDisableZdd, libcudd), Cvoid, (Ptr{DdManager},), unique)
end

function Cudd_ReorderingStatusZdd(unique, method)
    ccall((:Cudd_ReorderingStatusZdd, libcudd), Cint, (Ptr{DdManager}, Ptr{Cudd_ReorderingType}), unique, method)
end

function Cudd_zddRealignmentEnabled(unique)
    ccall((:Cudd_zddRealignmentEnabled, libcudd), Cint, (Ptr{DdManager},), unique)
end

function Cudd_zddRealignEnable(unique)
    ccall((:Cudd_zddRealignEnable, libcudd), Cvoid, (Ptr{DdManager},), unique)
end

function Cudd_zddRealignDisable(unique)
    ccall((:Cudd_zddRealignDisable, libcudd), Cvoid, (Ptr{DdManager},), unique)
end

function Cudd_bddRealignmentEnabled(unique)
    ccall((:Cudd_bddRealignmentEnabled, libcudd), Cint, (Ptr{DdManager},), unique)
end

function Cudd_bddRealignEnable(unique)
    ccall((:Cudd_bddRealignEnable, libcudd), Cvoid, (Ptr{DdManager},), unique)
end

function Cudd_bddRealignDisable(unique)
    ccall((:Cudd_bddRealignDisable, libcudd), Cvoid, (Ptr{DdManager},), unique)
end

function Cudd_ReadOne(dd)
    ccall((:Cudd_ReadOne, libcudd), Ptr{DdNode}, (Ptr{DdManager},), dd)
end

function Cudd_ReadZddOne(dd, i)
    ccall((:Cudd_ReadZddOne, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint), dd, i)
end

function Cudd_ReadZero(dd)
    ccall((:Cudd_ReadZero, libcudd), Ptr{DdNode}, (Ptr{DdManager},), dd)
end

function Cudd_ReadLogicZero(dd)
    ccall((:Cudd_ReadLogicZero, libcudd), Ptr{DdNode}, (Ptr{DdManager},), dd)
end

function Cudd_ReadPlusInfinity(dd)
    ccall((:Cudd_ReadPlusInfinity, libcudd), Ptr{DdNode}, (Ptr{DdManager},), dd)
end

function Cudd_ReadMinusInfinity(dd)
    ccall((:Cudd_ReadMinusInfinity, libcudd), Ptr{DdNode}, (Ptr{DdManager},), dd)
end

function Cudd_ReadBackground(dd)
    ccall((:Cudd_ReadBackground, libcudd), Ptr{DdNode}, (Ptr{DdManager},), dd)
end

function Cudd_SetBackground(dd, bck)
    ccall((:Cudd_SetBackground, libcudd), Cvoid, (Ptr{DdManager}, Ptr{DdNode}), dd, bck)
end

function Cudd_ReadCacheSlots(dd)
    ccall((:Cudd_ReadCacheSlots, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_ReadCacheUsedSlots(dd)
    ccall((:Cudd_ReadCacheUsedSlots, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_ReadCacheLookUps(dd)
    ccall((:Cudd_ReadCacheLookUps, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_ReadCacheHits(dd)
    ccall((:Cudd_ReadCacheHits, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_ReadRecursiveCalls(dd)
    ccall((:Cudd_ReadRecursiveCalls, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_ReadMinHit(dd)
    ccall((:Cudd_ReadMinHit, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_SetMinHit(dd, hr)
    ccall((:Cudd_SetMinHit, libcudd), Cvoid, (Ptr{DdManager}, UInt32), dd, hr)
end

function Cudd_ReadLooseUpTo(dd)
    ccall((:Cudd_ReadLooseUpTo, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_SetLooseUpTo(dd, lut)
    ccall((:Cudd_SetLooseUpTo, libcudd), Cvoid, (Ptr{DdManager}, UInt32), dd, lut)
end

function Cudd_ReadMaxCache(dd)
    ccall((:Cudd_ReadMaxCache, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_ReadMaxCacheHard(dd)
    ccall((:Cudd_ReadMaxCacheHard, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_SetMaxCacheHard(dd, mc)
    ccall((:Cudd_SetMaxCacheHard, libcudd), Cvoid, (Ptr{DdManager}, UInt32), dd, mc)
end

function Cudd_ReadSize(dd)
    ccall((:Cudd_ReadSize, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_ReadZddSize(dd)
    ccall((:Cudd_ReadZddSize, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_ReadSlots(dd)
    ccall((:Cudd_ReadSlots, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_ReadUsedSlots(dd)
    ccall((:Cudd_ReadUsedSlots, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_ExpectedUsedSlots(dd)
    ccall((:Cudd_ExpectedUsedSlots, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_ReadKeys(dd)
    ccall((:Cudd_ReadKeys, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_ReadDead(dd)
    ccall((:Cudd_ReadDead, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_ReadMinDead(dd)
    ccall((:Cudd_ReadMinDead, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_ReadReorderings(dd)
    ccall((:Cudd_ReadReorderings, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_ReadMaxReorderings(dd)
    ccall((:Cudd_ReadMaxReorderings, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_SetMaxReorderings(dd, mr)
    ccall((:Cudd_SetMaxReorderings, libcudd), Cvoid, (Ptr{DdManager}, UInt32), dd, mr)
end

function Cudd_ReadReorderingTime(dd)
    ccall((:Cudd_ReadReorderingTime, libcudd), Clong, (Ptr{DdManager},), dd)
end

function Cudd_ReadGarbageCollections(dd)
    ccall((:Cudd_ReadGarbageCollections, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_ReadGarbageCollectionTime(dd)
    ccall((:Cudd_ReadGarbageCollectionTime, libcudd), Clong, (Ptr{DdManager},), dd)
end

function Cudd_ReadNodesFreed(dd)
    ccall((:Cudd_ReadNodesFreed, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_ReadNodesDropped(dd)
    ccall((:Cudd_ReadNodesDropped, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_ReadUniqueLookUps(dd)
    ccall((:Cudd_ReadUniqueLookUps, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_ReadUniqueLinks(dd)
    ccall((:Cudd_ReadUniqueLinks, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_ReadSiftMaxVar(dd)
    ccall((:Cudd_ReadSiftMaxVar, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_SetSiftMaxVar(dd, smv)
    ccall((:Cudd_SetSiftMaxVar, libcudd), Cvoid, (Ptr{DdManager}, Cint), dd, smv)
end

function Cudd_ReadSiftMaxSwap(dd)
    ccall((:Cudd_ReadSiftMaxSwap, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_SetSiftMaxSwap(dd, sms)
    ccall((:Cudd_SetSiftMaxSwap, libcudd), Cvoid, (Ptr{DdManager}, Cint), dd, sms)
end

function Cudd_ReadMaxGrowth(dd)
    ccall((:Cudd_ReadMaxGrowth, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_SetMaxGrowth(dd, mg)
    ccall((:Cudd_SetMaxGrowth, libcudd), Cvoid, (Ptr{DdManager}, Cdouble), dd, mg)
end

function Cudd_ReadMaxGrowthAlternate(dd)
    ccall((:Cudd_ReadMaxGrowthAlternate, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_SetMaxGrowthAlternate(dd, mg)
    ccall((:Cudd_SetMaxGrowthAlternate, libcudd), Cvoid, (Ptr{DdManager}, Cdouble), dd, mg)
end

function Cudd_ReadReorderingCycle(dd)
    ccall((:Cudd_ReadReorderingCycle, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_SetReorderingCycle(dd, cycle)
    ccall((:Cudd_SetReorderingCycle, libcudd), Cvoid, (Ptr{DdManager}, Cint), dd, cycle)
end

function Cudd_NodeReadIndex(node)
    ccall((:Cudd_NodeReadIndex, libcudd), UInt32, (Ptr{DdNode},), node)
end

function Cudd_ReadPerm(dd, i)
    ccall((:Cudd_ReadPerm, libcudd), Cint, (Ptr{DdManager}, Cint), dd, i)
end

function Cudd_ReadPermZdd(dd, i)
    ccall((:Cudd_ReadPermZdd, libcudd), Cint, (Ptr{DdManager}, Cint), dd, i)
end

function Cudd_ReadInvPerm(dd, i)
    ccall((:Cudd_ReadInvPerm, libcudd), Cint, (Ptr{DdManager}, Cint), dd, i)
end

function Cudd_ReadInvPermZdd(dd, i)
    ccall((:Cudd_ReadInvPermZdd, libcudd), Cint, (Ptr{DdManager}, Cint), dd, i)
end

function Cudd_ReadVars(dd, i)
    ccall((:Cudd_ReadVars, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint), dd, i)
end

function Cudd_ReadEpsilon(dd)
    ccall((:Cudd_ReadEpsilon, libcudd), CUDD_VALUE_TYPE, (Ptr{DdManager},), dd)
end

function Cudd_SetEpsilon(dd, ep)
    ccall((:Cudd_SetEpsilon, libcudd), Cvoid, (Ptr{DdManager}, CUDD_VALUE_TYPE), dd, ep)
end

function Cudd_ReadGroupcheck(dd)
    ccall((:Cudd_ReadGroupcheck, libcudd), Cudd_AggregationType, (Ptr{DdManager},), dd)
end

function Cudd_SetGroupcheck(dd, gc)
    ccall((:Cudd_SetGroupcheck, libcudd), Cvoid, (Ptr{DdManager}, Cudd_AggregationType), dd, gc)
end

function Cudd_GarbageCollectionEnabled(dd)
    ccall((:Cudd_GarbageCollectionEnabled, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_EnableGarbageCollection(dd)
    ccall((:Cudd_EnableGarbageCollection, libcudd), Cvoid, (Ptr{DdManager},), dd)
end

function Cudd_DisableGarbageCollection(dd)
    ccall((:Cudd_DisableGarbageCollection, libcudd), Cvoid, (Ptr{DdManager},), dd)
end

function Cudd_DeadAreCounted(dd)
    ccall((:Cudd_DeadAreCounted, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_TurnOnCountDead(dd)
    ccall((:Cudd_TurnOnCountDead, libcudd), Cvoid, (Ptr{DdManager},), dd)
end

function Cudd_TurnOffCountDead(dd)
    ccall((:Cudd_TurnOffCountDead, libcudd), Cvoid, (Ptr{DdManager},), dd)
end

function Cudd_ReadRecomb(dd)
    ccall((:Cudd_ReadRecomb, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_SetRecomb(dd, recomb)
    ccall((:Cudd_SetRecomb, libcudd), Cvoid, (Ptr{DdManager}, Cint), dd, recomb)
end

function Cudd_ReadSymmviolation(dd)
    ccall((:Cudd_ReadSymmviolation, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_SetSymmviolation(dd, symmviolation)
    ccall((:Cudd_SetSymmviolation, libcudd), Cvoid, (Ptr{DdManager}, Cint), dd, symmviolation)
end

function Cudd_ReadArcviolation(dd)
    ccall((:Cudd_ReadArcviolation, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_SetArcviolation(dd, arcviolation)
    ccall((:Cudd_SetArcviolation, libcudd), Cvoid, (Ptr{DdManager}, Cint), dd, arcviolation)
end

function Cudd_ReadPopulationSize(dd)
    ccall((:Cudd_ReadPopulationSize, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_SetPopulationSize(dd, populationSize)
    ccall((:Cudd_SetPopulationSize, libcudd), Cvoid, (Ptr{DdManager}, Cint), dd, populationSize)
end

function Cudd_ReadNumberXovers(dd)
    ccall((:Cudd_ReadNumberXovers, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_SetNumberXovers(dd, numberXovers)
    ccall((:Cudd_SetNumberXovers, libcudd), Cvoid, (Ptr{DdManager}, Cint), dd, numberXovers)
end

function Cudd_ReadOrderRandomization(dd)
    ccall((:Cudd_ReadOrderRandomization, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_SetOrderRandomization(dd, factor)
    ccall((:Cudd_SetOrderRandomization, libcudd), Cvoid, (Ptr{DdManager}, UInt32), dd, factor)
end

function Cudd_ReadMemoryInUse()
    ccall((:Cudd_ReadMemoryInUse, libcudd), Cint, ())
end

function Cudd_PrintInfo(dd, fp)
    ccall((:Cudd_PrintInfo, libcudd), Cint, (Ptr{DdManager}, Ptr{Cint}), dd, fp)
end

function Cudd_ReadPeakNodeCount(dd)
    ccall((:Cudd_ReadPeakNodeCount, libcudd), Clong, (Ptr{DdManager},), dd)
end

function Cudd_ReadPeakLiveNodeCount(dd)
    ccall((:Cudd_ReadPeakLiveNodeCount, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_ReadNodeCount(dd)
    ccall((:Cudd_ReadNodeCount, libcudd), Clong, (Ptr{DdManager},), dd)
end

function Cudd_zddReadNodeCount(dd)
    ccall((:Cudd_zddReadNodeCount, libcudd), Clong, (Ptr{DdManager},), dd)
end

function Cudd_AddHook(dd, f, where)
    ccall((:Cudd_AddHook, libcudd), Cint, (Ptr{DdManager}, DD_HFP, Cudd_HookType), dd, f, where)
end

function Cudd_RemoveHook(dd, f, where)
    ccall((:Cudd_RemoveHook, libcudd), Cint, (Ptr{DdManager}, DD_HFP, Cudd_HookType), dd, f, where)
end

function Cudd_IsInHook(dd, f, where)
    ccall((:Cudd_IsInHook, libcudd), Cint, (Ptr{DdManager}, DD_HFP, Cudd_HookType), dd, f, where)
end

function Cudd_StdPreReordHook(dd, str, data)
    ccall((:Cudd_StdPreReordHook, libcudd), Cint, (Ptr{DdManager}, Cstring, Ptr{Cvoid}), dd, str, data)
end

function Cudd_StdPostReordHook(dd, str, data)
    ccall((:Cudd_StdPostReordHook, libcudd), Cint, (Ptr{DdManager}, Cstring, Ptr{Cvoid}), dd, str, data)
end

function Cudd_EnableReorderingReporting(dd)
    ccall((:Cudd_EnableReorderingReporting, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_DisableReorderingReporting(dd)
    ccall((:Cudd_DisableReorderingReporting, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_ReorderingReporting(dd)
    ccall((:Cudd_ReorderingReporting, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_PrintGroupedOrder(dd, str, data)
    ccall((:Cudd_PrintGroupedOrder, libcudd), Cint, (Ptr{DdManager}, Cstring, Ptr{Cvoid}), dd, str, data)
end

function Cudd_EnableOrderingMonitoring(dd)
    ccall((:Cudd_EnableOrderingMonitoring, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_DisableOrderingMonitoring(dd)
    ccall((:Cudd_DisableOrderingMonitoring, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_OrderingMonitoring(dd)
    ccall((:Cudd_OrderingMonitoring, libcudd), Cint, (Ptr{DdManager},), dd)
end

function Cudd_SetApplicationHook(dd, value)
    ccall((:Cudd_SetApplicationHook, libcudd), Cvoid, (Ptr{DdManager}, Ptr{Cvoid}), dd, value)
end

function Cudd_ReadApplicationHook(dd)
    ccall((:Cudd_ReadApplicationHook, libcudd), Ptr{Cvoid}, (Ptr{DdManager},), dd)
end

function Cudd_ReadErrorCode(dd)
    ccall((:Cudd_ReadErrorCode, libcudd), Cudd_ErrorType, (Ptr{DdManager},), dd)
end

function Cudd_ClearErrorCode(dd)
    ccall((:Cudd_ClearErrorCode, libcudd), Cvoid, (Ptr{DdManager},), dd)
end

function Cudd_InstallOutOfMemoryHandler(newHandler)
    ccall((:Cudd_InstallOutOfMemoryHandler, libcudd), DD_OOMFP, (DD_OOMFP,), newHandler)
end

function Cudd_ReadStdout()
    ccall((:Cudd_ReadStdout, libcudd), Ptr{Cint}, ())
end

function Cudd_SetStdout(dd, fp)
    ccall((:Cudd_SetStdout, libcudd), Cvoid, (Ptr{DdManager}, Ptr{Cint}), dd, fp)
end

function Cudd_ReadStderr()
    ccall((:Cudd_ReadStderr, libcudd), Ptr{Cint}, ())
end

function Cudd_SetStderr(dd, fp)
    ccall((:Cudd_SetStderr, libcudd), Cvoid, (Ptr{DdManager}, Ptr{Cint}), dd, fp)
end

function Cudd_ReadNextReordering(dd)
    ccall((:Cudd_ReadNextReordering, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_SetNextReordering(dd, next)
    ccall((:Cudd_SetNextReordering, libcudd), Cvoid, (Ptr{DdManager}, UInt32), dd, next)
end

function Cudd_ReadSwapSteps(dd)
    ccall((:Cudd_ReadSwapSteps, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_ReadMaxLive(dd)
    ccall((:Cudd_ReadMaxLive, libcudd), UInt32, (Ptr{DdManager},), dd)
end

function Cudd_SetMaxLive(dd, maxLive)
    ccall((:Cudd_SetMaxLive, libcudd), Cvoid, (Ptr{DdManager}, UInt32), dd, maxLive)
end

function Cudd_ReadMaxMemory()
    ccall((:Cudd_ReadMaxMemory, libcudd), Cint, ())
end

function Cudd_SetMaxMemory()
    ccall((:Cudd_SetMaxMemory, libcudd), Cint, ())
end

function Cudd_bddBindVar(dd, index)
    ccall((:Cudd_bddBindVar, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddUnbindVar(dd, index)
    ccall((:Cudd_bddUnbindVar, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddVarIsBound(dd, index)
    ccall((:Cudd_bddVarIsBound, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_addExistAbstract(manager, f, cube)
    ccall((:Cudd_addExistAbstract, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), manager, f, cube)
end

function Cudd_addUnivAbstract(manager, f, cube)
    ccall((:Cudd_addUnivAbstract, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), manager, f, cube)
end

function Cudd_addOrAbstract(manager, f, cube)
    ccall((:Cudd_addOrAbstract, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), manager, f, cube)
end

function Cudd_addApply(dd, op, f, g)
    ccall((:Cudd_addApply, libcudd), Ptr{DdNode}, (Ptr{DdManager}, DD_AOP, Ptr{DdNode}, Ptr{DdNode}), dd, op, f, g)
end

function Cudd_addPlus(dd, f, g)
    ccall((:Cudd_addPlus, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addTimes(dd, f, g)
    ccall((:Cudd_addTimes, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addThreshold(dd, f, g)
    ccall((:Cudd_addThreshold, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addSetNZ(dd, f, g)
    ccall((:Cudd_addSetNZ, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addDivide(dd, f, g)
    ccall((:Cudd_addDivide, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addMinus(dd, f, g)
    ccall((:Cudd_addMinus, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addMinimum(dd, f, g)
    ccall((:Cudd_addMinimum, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addMaximum(dd, f, g)
    ccall((:Cudd_addMaximum, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addOneZeroMaximum(dd, f, g)
    ccall((:Cudd_addOneZeroMaximum, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addDiff(dd, f, g)
    ccall((:Cudd_addDiff, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addAgreement(dd, f, g)
    ccall((:Cudd_addAgreement, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addOr(dd, f, g)
    ccall((:Cudd_addOr, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addNand(dd, f, g)
    ccall((:Cudd_addNand, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addNor(dd, f, g)
    ccall((:Cudd_addNor, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addXor(dd, f, g)
    ccall((:Cudd_addXor, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addXnor(dd, f, g)
    ccall((:Cudd_addXnor, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g)
end

function Cudd_addMonadicApply(dd, op, f)
    ccall((:Cudd_addMonadicApply, libcudd), Ptr{DdNode}, (Ptr{DdManager}, DD_MAOP, Ptr{DdNode}), dd, op, f)
end

function Cudd_addLog(dd, f)
    ccall((:Cudd_addLog, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_addFindMax(dd, f)
    ccall((:Cudd_addFindMax, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_addFindMin(dd, f)
    ccall((:Cudd_addFindMin, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_addIthBit(dd, f, bit)
    ccall((:Cudd_addIthBit, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint), dd, f, bit)
end

function Cudd_addScalarInverse(dd, f, epsilon)
    ccall((:Cudd_addScalarInverse, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, epsilon)
end

function Cudd_addIte(dd, f, g, h)
    ccall((:Cudd_addIte, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g, h)
end

function Cudd_addIteConstant(dd, f, g, h)
    ccall((:Cudd_addIteConstant, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g, h)
end

function Cudd_addEvalConst(dd, f, g)
    ccall((:Cudd_addEvalConst, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_addLeq(dd, f, g)
    ccall((:Cudd_addLeq, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_addCmpl(dd, f)
    ccall((:Cudd_addCmpl, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_addNegate(dd, f)
    ccall((:Cudd_addNegate, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_addRoundOff(dd, f, N)
    ccall((:Cudd_addRoundOff, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint), dd, f, N)
end

function Cudd_addWalsh(dd, x, y, n)
    ccall((:Cudd_addWalsh, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}, Cint), dd, x, y, n)
end

function Cudd_addResidue(dd, n, m, options, top)
    ccall((:Cudd_addResidue, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint, Cint, Cint, Cint), dd, n, m, options, top)
end

function Cudd_bddAndAbstract(manager, f, g, cube)
    ccall((:Cudd_bddAndAbstract, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}), manager, f, g, cube)
end

function Cudd_bddAndAbstractLimit(manager, f, g, cube, limit)
    ccall((:Cudd_bddAndAbstractLimit, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}, UInt32), manager, f, g, cube, limit)
end

function Cudd_ApaNumberOfDigits(binaryDigits)
    ccall((:Cudd_ApaNumberOfDigits, libcudd), Cint, (Cint,), binaryDigits)
end

function Cudd_NewApaNumber(digits)
    ccall((:Cudd_NewApaNumber, libcudd), DdApaNumber, (Cint,), digits)
end

function Cudd_FreeApaNumber(number)
    ccall((:Cudd_FreeApaNumber, libcudd), Cvoid, (DdApaNumber,), number)
end

function Cudd_ApaCopy(digits, source, dest)
    ccall((:Cudd_ApaCopy, libcudd), Cvoid, (Cint, DdConstApaNumber, DdApaNumber), digits, source, dest)
end

function Cudd_ApaAdd(digits, a, b, sum)
    ccall((:Cudd_ApaAdd, libcudd), DdApaDigit, (Cint, DdConstApaNumber, DdConstApaNumber, DdApaNumber), digits, a, b, sum)
end

function Cudd_ApaSubtract(digits, a, b, diff)
    ccall((:Cudd_ApaSubtract, libcudd), DdApaDigit, (Cint, DdConstApaNumber, DdConstApaNumber, DdApaNumber), digits, a, b, diff)
end

function Cudd_ApaShortDivision(digits, dividend, divisor, quotient)
    ccall((:Cudd_ApaShortDivision, libcudd), DdApaDigit, (Cint, DdConstApaNumber, DdApaDigit, DdApaNumber), digits, dividend, divisor, quotient)
end

function Cudd_ApaIntDivision(digits, dividend, divisor, quotient)
    ccall((:Cudd_ApaIntDivision, libcudd), UInt32, (Cint, DdConstApaNumber, UInt32, DdApaNumber), digits, dividend, divisor, quotient)
end

function Cudd_ApaShiftRight(digits, in, a, b)
    ccall((:Cudd_ApaShiftRight, libcudd), Cvoid, (Cint, DdApaDigit, DdConstApaNumber, DdApaNumber), digits, in, a, b)
end

function Cudd_ApaSetToLiteral(digits, number, literal)
    ccall((:Cudd_ApaSetToLiteral, libcudd), Cvoid, (Cint, DdApaNumber, DdApaDigit), digits, number, literal)
end

function Cudd_ApaPowerOfTwo(digits, number, power)
    ccall((:Cudd_ApaPowerOfTwo, libcudd), Cvoid, (Cint, DdApaNumber, Cint), digits, number, power)
end

function Cudd_ApaCompare(digitsFirst, first, digitsSecond, second)
    ccall((:Cudd_ApaCompare, libcudd), Cint, (Cint, DdConstApaNumber, Cint, DdConstApaNumber), digitsFirst, first, digitsSecond, second)
end

function Cudd_ApaCompareRatios(digitsFirst, firstNum, firstDen, digitsSecond, secondNum, secondDen)
    ccall((:Cudd_ApaCompareRatios, libcudd), Cint, (Cint, DdConstApaNumber, UInt32, Cint, DdConstApaNumber, UInt32), digitsFirst, firstNum, firstDen, digitsSecond, secondNum, secondDen)
end

function Cudd_ApaPrintHex(fp, digits, number)
    ccall((:Cudd_ApaPrintHex, libcudd), Cint, (Ptr{Cint}, Cint, DdConstApaNumber), fp, digits, number)
end

function Cudd_ApaPrintDecimal(fp, digits, number)
    ccall((:Cudd_ApaPrintDecimal, libcudd), Cint, (Ptr{Cint}, Cint, DdConstApaNumber), fp, digits, number)
end

function Cudd_ApaStringDecimal(digits, number)
    ccall((:Cudd_ApaStringDecimal, libcudd), Cstring, (Cint, DdConstApaNumber), digits, number)
end

function Cudd_ApaPrintExponential(fp, digits, number, precision)
    ccall((:Cudd_ApaPrintExponential, libcudd), Cint, (Ptr{Cint}, Cint, DdConstApaNumber, Cint), fp, digits, number, precision)
end

function Cudd_ApaCountMinterm(manager, node, nvars, digits)
    ccall((:Cudd_ApaCountMinterm, libcudd), DdApaNumber, (Ptr{DdManager}, Ptr{DdNode}, Cint, Ptr{Cint}), manager, node, nvars, digits)
end

function Cudd_ApaPrintMinterm(fp, dd, node, nvars)
    ccall((:Cudd_ApaPrintMinterm, libcudd), Cint, (Ptr{Cint}, Ptr{DdManager}, Ptr{DdNode}, Cint), fp, dd, node, nvars)
end

function Cudd_ApaPrintMintermExp(fp, dd, node, nvars, precision)
    ccall((:Cudd_ApaPrintMintermExp, libcudd), Cint, (Ptr{Cint}, Ptr{DdManager}, Ptr{DdNode}, Cint, Cint), fp, dd, node, nvars, precision)
end

function Cudd_ApaPrintDensity(fp, dd, node, nvars)
    ccall((:Cudd_ApaPrintDensity, libcudd), Cint, (Ptr{Cint}, Ptr{DdManager}, Ptr{DdNode}, Cint), fp, dd, node, nvars)
end

function Cudd_UnderApprox(dd, f, numVars, threshold, safe, quality)
    ccall((:Cudd_UnderApprox, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint, Cint, Cdouble), dd, f, numVars, threshold, safe, quality)
end

function Cudd_OverApprox(dd, f, numVars, threshold, safe, quality)
    ccall((:Cudd_OverApprox, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint, Cint, Cdouble), dd, f, numVars, threshold, safe, quality)
end

function Cudd_RemapUnderApprox(dd, f, numVars, threshold, quality)
    ccall((:Cudd_RemapUnderApprox, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint, Cdouble), dd, f, numVars, threshold, quality)
end

function Cudd_RemapOverApprox(dd, f, numVars, threshold, quality)
    ccall((:Cudd_RemapOverApprox, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint, Cdouble), dd, f, numVars, threshold, quality)
end

function Cudd_BiasedUnderApprox(dd, f, b, numVars, threshold, quality1, quality0)
    ccall((:Cudd_BiasedUnderApprox, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Cint, Cint, Cdouble, Cdouble), dd, f, b, numVars, threshold, quality1, quality0)
end

function Cudd_BiasedOverApprox(dd, f, b, numVars, threshold, quality1, quality0)
    ccall((:Cudd_BiasedOverApprox, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Cint, Cint, Cdouble, Cdouble), dd, f, b, numVars, threshold, quality1, quality0)
end

function Cudd_bddExistAbstract(manager, f, cube)
    ccall((:Cudd_bddExistAbstract, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), manager, f, cube)
end

function Cudd_bddExistAbstractLimit(manager, f, cube, limit)
    ccall((:Cudd_bddExistAbstractLimit, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, UInt32), manager, f, cube, limit)
end

function Cudd_bddXorExistAbstract(manager, f, g, cube)
    ccall((:Cudd_bddXorExistAbstract, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}), manager, f, g, cube)
end

function Cudd_bddUnivAbstract(manager, f, cube)
    ccall((:Cudd_bddUnivAbstract, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), manager, f, cube)
end

function Cudd_bddBooleanDiff(manager, f, x)
    ccall((:Cudd_bddBooleanDiff, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint), manager, f, x)
end

function Cudd_bddVarIsDependent(dd, f, var)
    ccall((:Cudd_bddVarIsDependent, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, var)
end

function Cudd_bddCorrelation(manager, f, g)
    ccall((:Cudd_bddCorrelation, libcudd), Cdouble, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), manager, f, g)
end

function Cudd_bddCorrelationWeights(manager, f, g, prob)
    ccall((:Cudd_bddCorrelationWeights, libcudd), Cdouble, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{Cdouble}), manager, f, g, prob)
end

function Cudd_bddIte(dd, f, g, h)
    ccall((:Cudd_bddIte, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g, h)
end

function Cudd_bddIteLimit(dd, f, g, h, limit)
    ccall((:Cudd_bddIteLimit, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}, UInt32), dd, f, g, h, limit)
end

function Cudd_bddIteConstant(dd, f, g, h)
    ccall((:Cudd_bddIteConstant, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g, h)
end

function Cudd_bddIntersect(dd, f, g)
    ccall((:Cudd_bddIntersect, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_bddAnd(dd, f, g)
    ccall((:Cudd_bddAnd, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_bddAndLimit(dd, f, g, limit)
    ccall((:Cudd_bddAndLimit, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, UInt32), dd, f, g, limit)
end

function Cudd_bddOr(dd, f, g)
    ccall((:Cudd_bddOr, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_bddOrLimit(dd, f, g, limit)
    ccall((:Cudd_bddOrLimit, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, UInt32), dd, f, g, limit)
end

function Cudd_bddNand(dd, f, g)
    ccall((:Cudd_bddNand, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_bddNor(dd, f, g)
    ccall((:Cudd_bddNor, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_bddXor(dd, f, g)
    ccall((:Cudd_bddXor, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_bddXnor(dd, f, g)
    ccall((:Cudd_bddXnor, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_bddXnorLimit(dd, f, g, limit)
    ccall((:Cudd_bddXnorLimit, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, UInt32), dd, f, g, limit)
end

function Cudd_bddLeq(dd, f, g)
    ccall((:Cudd_bddLeq, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_addBddThreshold(dd, f, value)
    ccall((:Cudd_addBddThreshold, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, CUDD_VALUE_TYPE), dd, f, value)
end

function Cudd_addBddStrictThreshold(dd, f, value)
    ccall((:Cudd_addBddStrictThreshold, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, CUDD_VALUE_TYPE), dd, f, value)
end

function Cudd_addBddInterval(dd, f, lower, upper)
    ccall((:Cudd_addBddInterval, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, CUDD_VALUE_TYPE, CUDD_VALUE_TYPE), dd, f, lower, upper)
end

function Cudd_addBddIthBit(dd, f, bit)
    ccall((:Cudd_addBddIthBit, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint), dd, f, bit)
end

function Cudd_BddToAdd(dd, B)
    ccall((:Cudd_BddToAdd, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, B)
end

function Cudd_addBddPattern(dd, f)
    ccall((:Cudd_addBddPattern, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_bddTransfer(ddSource, ddDestination, f)
    ccall((:Cudd_bddTransfer, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdManager}, Ptr{DdNode}), ddSource, ddDestination, f)
end

function Cudd_DebugCheck(table)
    ccall((:Cudd_DebugCheck, libcudd), Cint, (Ptr{DdManager},), table)
end

function Cudd_CheckKeys(table)
    ccall((:Cudd_CheckKeys, libcudd), Cint, (Ptr{DdManager},), table)
end

function Cudd_bddClippingAnd(dd, f, g, maxDepth, direction)
    ccall((:Cudd_bddClippingAnd, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Cint, Cint), dd, f, g, maxDepth, direction)
end

function Cudd_bddClippingAndAbstract(dd, f, g, cube, maxDepth, direction)
    ccall((:Cudd_bddClippingAndAbstract, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}, Cint, Cint), dd, f, g, cube, maxDepth, direction)
end

function Cudd_Cofactor(dd, f, g)
    ccall((:Cudd_Cofactor, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_CheckCube(dd, g)
    ccall((:Cudd_CheckCube, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}), dd, g)
end

function Cudd_VarsAreSymmetric(dd, f, index1, index2)
    ccall((:Cudd_VarsAreSymmetric, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint), dd, f, index1, index2)
end

function Cudd_bddCompose(dd, f, g, v)
    ccall((:Cudd_bddCompose, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Cint), dd, f, g, v)
end

function Cudd_addCompose(dd, f, g, v)
    ccall((:Cudd_addCompose, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Cint), dd, f, g, v)
end

function Cudd_addPermute(manager, node, permut)
    ccall((:Cudd_addPermute, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Cint}), manager, node, permut)
end

function Cudd_addSwapVariables(dd, f, x, y, n)
    ccall((:Cudd_addSwapVariables, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}, Cint), dd, f, x, y, n)
end

function Cudd_bddPermute(manager, node, permut)
    ccall((:Cudd_bddPermute, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Cint}), manager, node, permut)
end

function Cudd_bddVarMap(manager, f)
    ccall((:Cudd_bddVarMap, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), manager, f)
end

function Cudd_SetVarMap(manager, x, y, n)
    ccall((:Cudd_SetVarMap, libcudd), Cint, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}, Cint), manager, x, y, n)
end

function Cudd_bddSwapVariables(dd, f, x, y, n)
    ccall((:Cudd_bddSwapVariables, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}, Cint), dd, f, x, y, n)
end

function Cudd_bddAdjPermuteX(dd, B, x, n)
    ccall((:Cudd_bddAdjPermuteX, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Cint), dd, B, x, n)
end

function Cudd_addVectorCompose(dd, f, vector)
    ccall((:Cudd_addVectorCompose, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}), dd, f, vector)
end

function Cudd_addGeneralVectorCompose(dd, f, vectorOn, vectorOff)
    ccall((:Cudd_addGeneralVectorCompose, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, vectorOn, vectorOff)
end

function Cudd_addNonSimCompose(dd, f, vector)
    ccall((:Cudd_addNonSimCompose, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}), dd, f, vector)
end

function Cudd_bddVectorCompose(dd, f, vector)
    ccall((:Cudd_bddVectorCompose, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}), dd, f, vector)
end

function Cudd_bddApproxConjDecomp(dd, f, conjuncts)
    ccall((:Cudd_bddApproxConjDecomp, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{Ptr{DdNode}}}), dd, f, conjuncts)
end

function Cudd_bddApproxDisjDecomp(dd, f, disjuncts)
    ccall((:Cudd_bddApproxDisjDecomp, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{Ptr{DdNode}}}), dd, f, disjuncts)
end

function Cudd_bddIterConjDecomp(dd, f, conjuncts)
    ccall((:Cudd_bddIterConjDecomp, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{Ptr{DdNode}}}), dd, f, conjuncts)
end

function Cudd_bddIterDisjDecomp(dd, f, disjuncts)
    ccall((:Cudd_bddIterDisjDecomp, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{Ptr{DdNode}}}), dd, f, disjuncts)
end

function Cudd_bddGenConjDecomp(dd, f, conjuncts)
    ccall((:Cudd_bddGenConjDecomp, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{Ptr{DdNode}}}), dd, f, conjuncts)
end

function Cudd_bddGenDisjDecomp(dd, f, disjuncts)
    ccall((:Cudd_bddGenDisjDecomp, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{Ptr{DdNode}}}), dd, f, disjuncts)
end

function Cudd_bddVarConjDecomp(dd, f, conjuncts)
    ccall((:Cudd_bddVarConjDecomp, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{Ptr{DdNode}}}), dd, f, conjuncts)
end

function Cudd_bddVarDisjDecomp(dd, f, disjuncts)
    ccall((:Cudd_bddVarDisjDecomp, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{Ptr{DdNode}}}), dd, f, disjuncts)
end

function Cudd_FindEssential(dd, f)
    ccall((:Cudd_FindEssential, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_bddIsVarEssential(manager, f, id, phase)
    ccall((:Cudd_bddIsVarEssential, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint), manager, f, id, phase)
end

function Cudd_FindTwoLiteralClauses(dd, f)
    ccall((:Cudd_FindTwoLiteralClauses, libcudd), Ptr{DdTlcInfo}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_PrintTwoLiteralClauses(dd, f, names, fp)
    ccall((:Cudd_PrintTwoLiteralClauses, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Cstring}, Ptr{Cint}), dd, f, names, fp)
end

function Cudd_ReadIthClause(tlc, i, var1, var2, phase1, phase2)
    ccall((:Cudd_ReadIthClause, libcudd), Cint, (Ptr{DdTlcInfo}, Cint, Ptr{UInt32}, Ptr{UInt32}, Ptr{Cint}, Ptr{Cint}), tlc, i, var1, var2, phase1, phase2)
end

function Cudd_tlcInfoFree(t)
    ccall((:Cudd_tlcInfoFree, libcudd), Cvoid, (Ptr{DdTlcInfo},), t)
end

function Cudd_DumpBlif(dd, n, f, inames, onames, mname, fp, mv)
    ccall((:Cudd_DumpBlif, libcudd), Cint, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, Ptr{Cstring}, Ptr{Cstring}, Cstring, Ptr{Cint}, Cint), dd, n, f, inames, onames, mname, fp, mv)
end

function Cudd_DumpBlifBody(dd, n, f, inames, onames, fp, mv)
    ccall((:Cudd_DumpBlifBody, libcudd), Cint, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cint}, Cint), dd, n, f, inames, onames, fp, mv)
end

function Cudd_DumpDot(dd, n, f, inames, onames, fp)
    ccall((:Cudd_DumpDot, libcudd), Cint, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cint}), dd, n, f, inames, onames, fp)
end

function Cudd_DumpDaVinci(dd, n, f, inames, onames, fp)
    ccall((:Cudd_DumpDaVinci, libcudd), Cint, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cint}), dd, n, f, inames, onames, fp)
end

function Cudd_DumpDDcal(dd, n, f, inames, onames, fp)
    ccall((:Cudd_DumpDDcal, libcudd), Cint, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cint}), dd, n, f, inames, onames, fp)
end

function Cudd_DumpFactoredForm(dd, n, f, inames, onames, fp)
    ccall((:Cudd_DumpFactoredForm, libcudd), Cint, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cint}), dd, n, f, inames, onames, fp)
end

function Cudd_FactoredFormString(dd, f, inames)
    ccall((:Cudd_FactoredFormString, libcudd), Cstring, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Cstring}), dd, f, inames)
end

function Cudd_bddConstrain(dd, f, c)
    ccall((:Cudd_bddConstrain, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, c)
end

function Cudd_bddRestrict(dd, f, c)
    ccall((:Cudd_bddRestrict, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, c)
end

function Cudd_bddNPAnd(dd, f, c)
    ccall((:Cudd_bddNPAnd, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, c)
end

function Cudd_addConstrain(dd, f, c)
    ccall((:Cudd_addConstrain, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, c)
end

function Cudd_bddConstrainDecomp(dd, f)
    ccall((:Cudd_bddConstrainDecomp, libcudd), Ptr{Ptr{DdNode}}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_addRestrict(dd, f, c)
    ccall((:Cudd_addRestrict, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, c)
end

function Cudd_bddCharToVect(dd, f)
    ccall((:Cudd_bddCharToVect, libcudd), Ptr{Ptr{DdNode}}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_bddLICompaction(dd, f, c)
    ccall((:Cudd_bddLICompaction, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, c)
end

function Cudd_bddSqueeze(dd, l, u)
    ccall((:Cudd_bddSqueeze, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, l, u)
end

function Cudd_bddInterpolate(dd, l, u)
    ccall((:Cudd_bddInterpolate, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, l, u)
end

function Cudd_bddMinimize(dd, f, c)
    ccall((:Cudd_bddMinimize, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, c)
end

function Cudd_SubsetCompress(dd, f, nvars, threshold)
    ccall((:Cudd_SubsetCompress, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint), dd, f, nvars, threshold)
end

function Cudd_SupersetCompress(dd, f, nvars, threshold)
    ccall((:Cudd_SupersetCompress, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint), dd, f, nvars, threshold)
end

function Cudd_addHarwell(fp, dd, E, x, y, xn, yn_, nx, ny, m, n, bx, sx, by, sy, pr)
    ccall((:Cudd_addHarwell, libcudd), Cint, (Ptr{Cint}, Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{Ptr{DdNode}}}, Ptr{Ptr{Ptr{DdNode}}}, Ptr{Ptr{Ptr{DdNode}}}, Ptr{Ptr{Ptr{DdNode}}}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Cint, Cint, Cint, Cint, Cint), fp, dd, E, x, y, xn, yn_, nx, ny, m, n, bx, sx, by, sy, pr)
end

function Cudd_Init(numVars, numVarsZ, numSlots, cacheSize, maxMemory)
    ccall((:Cudd_Init, libcudd), Ptr{DdManager}, (UInt32, UInt32, UInt32, UInt32, Cint), numVars, numVarsZ, numSlots, cacheSize, maxMemory)
end

function Cudd_Quit(unique)
    ccall((:Cudd_Quit, libcudd), Cvoid, (Ptr{DdManager},), unique)
end

function Cudd_PrintLinear(table)
    ccall((:Cudd_PrintLinear, libcudd), Cint, (Ptr{DdManager},), table)
end

function Cudd_ReadLinear(table, x, y)
    ccall((:Cudd_ReadLinear, libcudd), Cint, (Ptr{DdManager}, Cint, Cint), table, x, y)
end

function Cudd_bddLiteralSetIntersection(dd, f, g)
    ccall((:Cudd_bddLiteralSetIntersection, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_addMatrixMultiply(dd, A, B, z, nz)
    ccall((:Cudd_addMatrixMultiply, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Cint), dd, A, B, z, nz)
end

function Cudd_addTimesPlus(dd, A, B, z, nz)
    ccall((:Cudd_addTimesPlus, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Cint), dd, A, B, z, nz)
end

function Cudd_addTriangle(dd, f, g, z, nz)
    ccall((:Cudd_addTriangle, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Cint), dd, f, g, z, nz)
end

function Cudd_addOuterSum(dd, M, r, c)
    ccall((:Cudd_addOuterSum, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}), dd, M, r, c)
end

function Cudd_PrioritySelect(dd, R, x, y, z, Pi, n, PiFunc)
    ccall((:Cudd_PrioritySelect, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}, Ptr{DdNode}, Cint, DD_PRFP), dd, R, x, y, z, Pi, n, PiFunc)
end

function Cudd_Xgty(dd, N, z, x, y)
    ccall((:Cudd_Xgty, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, N, z, x, y)
end

function Cudd_Xeqy(dd, N, x, y)
    ccall((:Cudd_Xeqy, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, N, x, y)
end

function Cudd_addXeqy(dd, N, x, y)
    ccall((:Cudd_addXeqy, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, N, x, y)
end

function Cudd_Dxygtdxz(dd, N, x, y, z)
    ccall((:Cudd_Dxygtdxz, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, N, x, y, z)
end

function Cudd_Dxygtdyz(dd, N, x, y, z)
    ccall((:Cudd_Dxygtdyz, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, N, x, y, z)
end

function Cudd_Inequality(dd, N, c, x, y)
    ccall((:Cudd_Inequality, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint, Cint, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, N, c, x, y)
end

function Cudd_Disequality(dd, N, c, x, y)
    ccall((:Cudd_Disequality, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint, Cint, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, N, c, x, y)
end

function Cudd_bddInterval(dd, N, x, lowerB, upperB)
    ccall((:Cudd_bddInterval, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, UInt32, UInt32), dd, N, x, lowerB, upperB)
end

function Cudd_CProjection(dd, R, Y)
    ccall((:Cudd_CProjection, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, R, Y)
end

function Cudd_addHamming(dd, xVars, yVars, nVars)
    ccall((:Cudd_addHamming, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}, Cint), dd, xVars, yVars, nVars)
end

function Cudd_MinHammingDist(dd, f, minterm, upperBound)
    ccall((:Cudd_MinHammingDist, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Cint}, Cint), dd, f, minterm, upperBound)
end

function Cudd_bddClosestCube(dd, f, g, distance)
    ccall((:Cudd_bddClosestCube, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{Cint}), dd, f, g, distance)
end

function Cudd_addRead(fp, dd, E, x, y, xn, yn_, nx, ny, m, n, bx, sx, by, sy)
    ccall((:Cudd_addRead, libcudd), Cint, (Ptr{Cint}, Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{Ptr{DdNode}}}, Ptr{Ptr{Ptr{DdNode}}}, Ptr{Ptr{Ptr{DdNode}}}, Ptr{Ptr{Ptr{DdNode}}}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Cint, Cint, Cint, Cint), fp, dd, E, x, y, xn, yn_, nx, ny, m, n, bx, sx, by, sy)
end

function Cudd_bddRead(fp, dd, E, x, y, nx, ny, m, n, bx, sx, by, sy)
    ccall((:Cudd_bddRead, libcudd), Cint, (Ptr{Cint}, Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Ptr{Ptr{DdNode}}}, Ptr{Ptr{Ptr{DdNode}}}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}, Cint, Cint, Cint, Cint), fp, dd, E, x, y, nx, ny, m, n, bx, sx, by, sy)
end

function Cudd_Ref(n)
    ccall((:Cudd_Ref, libcudd), Cvoid, (Ptr{DdNode},), n)
end

function Cudd_RecursiveDeref(table, n)
    ccall((:Cudd_RecursiveDeref, libcudd), Cvoid, (Ptr{DdManager}, Ptr{DdNode}), table, n)
end

function Cudd_IterDerefBdd(table, n)
    ccall((:Cudd_IterDerefBdd, libcudd), Cvoid, (Ptr{DdManager}, Ptr{DdNode}), table, n)
end

function Cudd_DelayedDerefBdd(table, n)
    ccall((:Cudd_DelayedDerefBdd, libcudd), Cvoid, (Ptr{DdManager}, Ptr{DdNode}), table, n)
end

function Cudd_RecursiveDerefZdd(table, n)
    ccall((:Cudd_RecursiveDerefZdd, libcudd), Cvoid, (Ptr{DdManager}, Ptr{DdNode}), table, n)
end

function Cudd_Deref(node)
    ccall((:Cudd_Deref, libcudd), Cvoid, (Ptr{DdNode},), node)
end

function Cudd_CheckZeroRef(manager)
    ccall((:Cudd_CheckZeroRef, libcudd), Cint, (Ptr{DdManager},), manager)
end

function Cudd_ReduceHeap(table, heuristic, minsize)
    ccall((:Cudd_ReduceHeap, libcudd), Cint, (Ptr{DdManager}, Cudd_ReorderingType, Cint), table, heuristic, minsize)
end

function Cudd_ShuffleHeap(table, permutation)
    ccall((:Cudd_ShuffleHeap, libcudd), Cint, (Ptr{DdManager}, Ptr{Cint}), table, permutation)
end

function Cudd_Eval(dd, f, inputs)
    ccall((:Cudd_Eval, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Cint}), dd, f, inputs)
end

function Cudd_ShortestPath(manager, f, weight, support, length)
    ccall((:Cudd_ShortestPath, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Cint}, Ptr{Cint}, Ptr{Cint}), manager, f, weight, support, length)
end

function Cudd_LargestCube(manager, f, length)
    ccall((:Cudd_LargestCube, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Cint}), manager, f, length)
end

function Cudd_ShortestLength(manager, f, weight)
    ccall((:Cudd_ShortestLength, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Cint}), manager, f, weight)
end

function Cudd_Decreasing(dd, f, i)
    ccall((:Cudd_Decreasing, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint), dd, f, i)
end

function Cudd_Increasing(dd, f, i)
    ccall((:Cudd_Increasing, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint), dd, f, i)
end

function Cudd_EquivDC(dd, F, G, D)
    ccall((:Cudd_EquivDC, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}), dd, F, G, D)
end

function Cudd_bddLeqUnless(dd, f, g, D)
    ccall((:Cudd_bddLeqUnless, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g, D)
end

function Cudd_EqualSupNorm(dd, f, g, tolerance, pr)
    ccall((:Cudd_EqualSupNorm, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, CUDD_VALUE_TYPE, Cint), dd, f, g, tolerance, pr)
end

function Cudd_bddMakePrime(dd, cube, f)
    ccall((:Cudd_bddMakePrime, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, cube, f)
end

function Cudd_bddMaximallyExpand(dd, lb, ub, f)
    ccall((:Cudd_bddMaximallyExpand, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}), dd, lb, ub, f)
end

function Cudd_bddLargestPrimeUnate(dd, f, phaseBdd)
    ccall((:Cudd_bddLargestPrimeUnate, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, phaseBdd)
end

function Cudd_CofMinterm(dd, node)
    ccall((:Cudd_CofMinterm, libcudd), Ptr{Cdouble}, (Ptr{DdManager}, Ptr{DdNode}), dd, node)
end

function Cudd_SolveEqn(bdd, F, Y, G, yIndex, n)
    ccall((:Cudd_SolveEqn, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Ptr{Ptr{Cint}}, Cint), bdd, F, Y, G, yIndex, n)
end

function Cudd_VerifySol(bdd, F, G, yIndex, n)
    ccall((:Cudd_VerifySol, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Ptr{Cint}, Cint), bdd, F, G, yIndex, n)
end

function Cudd_SplitSet(manager, S, xVars, n, m)
    ccall((:Cudd_SplitSet, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Cint, Cdouble), manager, S, xVars, n, m)
end

function Cudd_SubsetHeavyBranch(dd, f, numVars, threshold)
    ccall((:Cudd_SubsetHeavyBranch, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint), dd, f, numVars, threshold)
end

function Cudd_SupersetHeavyBranch(dd, f, numVars, threshold)
    ccall((:Cudd_SupersetHeavyBranch, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint), dd, f, numVars, threshold)
end

function Cudd_SubsetShortPaths(dd, f, numVars, threshold, hardlimit)
    ccall((:Cudd_SubsetShortPaths, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint, Cint), dd, f, numVars, threshold, hardlimit)
end

function Cudd_SupersetShortPaths(dd, f, numVars, threshold, hardlimit)
    ccall((:Cudd_SupersetShortPaths, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint, Cint), dd, f, numVars, threshold, hardlimit)
end

function Cudd_SymmProfile(table, lower, upper)
    ccall((:Cudd_SymmProfile, libcudd), Cvoid, (Ptr{DdManager}, Cint, Cint), table, lower, upper)
end

function Cudd_Prime(p)
    ccall((:Cudd_Prime, libcudd), UInt32, (UInt32,), p)
end

function Cudd_Reserve(manager, amount)
    ccall((:Cudd_Reserve, libcudd), Cint, (Ptr{DdManager}, Cint), manager, amount)
end

function Cudd_PrintMinterm(manager, node)
    ccall((:Cudd_PrintMinterm, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}), manager, node)
end

function Cudd_bddPrintCover(dd, l, u)
    ccall((:Cudd_bddPrintCover, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, l, u)
end

function Cudd_PrintDebug(dd, f, n, pr)
    ccall((:Cudd_PrintDebug, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint), dd, f, n, pr)
end

function Cudd_PrintSummary(dd, f, n, mode)
    ccall((:Cudd_PrintSummary, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint), dd, f, n, mode)
end

function Cudd_DagSize(node)
    ccall((:Cudd_DagSize, libcudd), Cint, (Ptr{DdNode},), node)
end

function Cudd_EstimateCofactor(dd, node, i, phase)
    ccall((:Cudd_EstimateCofactor, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint), dd, node, i, phase)
end

function Cudd_EstimateCofactorSimple(node, i)
    ccall((:Cudd_EstimateCofactorSimple, libcudd), Cint, (Ptr{DdNode}, Cint), node, i)
end

function Cudd_SharingSize(nodeArray, n)
    ccall((:Cudd_SharingSize, libcudd), Cint, (Ptr{Ptr{DdNode}}, Cint), nodeArray, n)
end

function Cudd_CountMinterm(manager, node, nvars)
    ccall((:Cudd_CountMinterm, libcudd), Cdouble, (Ptr{DdManager}, Ptr{DdNode}, Cint), manager, node, nvars)
end

function Cudd_LdblCountMinterm(manager, node, nvars)
    ccall((:Cudd_LdblCountMinterm, libcudd), Float64, (Ptr{DdManager}, Ptr{DdNode}, Cint), manager, node, nvars)
end

function Cudd_EpdPrintMinterm(dd, node, nvars)
    ccall((:Cudd_EpdPrintMinterm, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Cint), dd, node, nvars)
end

function Cudd_CountPath(node)
    ccall((:Cudd_CountPath, libcudd), Cdouble, (Ptr{DdNode},), node)
end

function Cudd_CountPathsToNonZero(node)
    ccall((:Cudd_CountPathsToNonZero, libcudd), Cdouble, (Ptr{DdNode},), node)
end

function Cudd_SupportIndices(dd, f, indices)
    ccall((:Cudd_SupportIndices, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{Cint}}), dd, f, indices)
end

function Cudd_Support(dd, f)
    ccall((:Cudd_Support, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_SupportIndex(dd, f)
    ccall((:Cudd_SupportIndex, libcudd), Ptr{Cint}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_SupportSize(dd, f)
    ccall((:Cudd_SupportSize, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_VectorSupportIndices(dd, F, n, indices)
    ccall((:Cudd_VectorSupportIndices, libcudd), Cint, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Cint, Ptr{Ptr{Cint}}), dd, F, n, indices)
end

function Cudd_VectorSupport(dd, F, n)
    ccall((:Cudd_VectorSupport, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Cint), dd, F, n)
end

function Cudd_VectorSupportIndex(dd, F, n)
    ccall((:Cudd_VectorSupportIndex, libcudd), Ptr{Cint}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Cint), dd, F, n)
end

function Cudd_VectorSupportSize(dd, F, n)
    ccall((:Cudd_VectorSupportSize, libcudd), Cint, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Cint), dd, F, n)
end

function Cudd_ClassifySupport(dd, f, g, common, onlyF, onlyG)
    ccall((:Cudd_ClassifySupport, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}, Ptr{Ptr{DdNode}}), dd, f, g, common, onlyF, onlyG)
end

function Cudd_CountLeaves(node)
    ccall((:Cudd_CountLeaves, libcudd), Cint, (Ptr{DdNode},), node)
end

function Cudd_bddPickOneCube(ddm, node, string)
    ccall((:Cudd_bddPickOneCube, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Cstring), ddm, node, string)
end

function Cudd_bddPickOneMinterm(dd, f, vars, n)
    ccall((:Cudd_bddPickOneMinterm, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Cint), dd, f, vars, n)
end

function Cudd_bddPickArbitraryMinterms(dd, f, vars, n, k)
    ccall((:Cudd_bddPickArbitraryMinterms, libcudd), Ptr{Ptr{DdNode}}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Cint, Cint), dd, f, vars, n, k)
end

function Cudd_SubsetWithMaskVars(dd, f, vars, nvars, maskVars, mvars)
    ccall((:Cudd_SubsetWithMaskVars, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}, Cint, Ptr{Ptr{DdNode}}, Cint), dd, f, vars, nvars, maskVars, mvars)
end

function Cudd_FirstCube(dd, f, cube, value)
    ccall((:Cudd_FirstCube, libcudd), Ptr{DdGen}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{Cint}}, Ptr{CUDD_VALUE_TYPE}), dd, f, cube, value)
end

function Cudd_NextCube(gen, cube, value)
    ccall((:Cudd_NextCube, libcudd), Cint, (Ptr{DdGen}, Ptr{Ptr{Cint}}, Ptr{CUDD_VALUE_TYPE}), gen, cube, value)
end

function Cudd_FirstPrime(dd, l, u, cube)
    ccall((:Cudd_FirstPrime, libcudd), Ptr{DdGen}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{Ptr{Cint}}), dd, l, u, cube)
end

function Cudd_NextPrime(gen, cube)
    ccall((:Cudd_NextPrime, libcudd), Cint, (Ptr{DdGen}, Ptr{Ptr{Cint}}), gen, cube)
end

function Cudd_bddComputeCube(dd, vars, phase, n)
    ccall((:Cudd_bddComputeCube, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Cint}, Cint), dd, vars, phase, n)
end

function Cudd_addComputeCube(dd, vars, phase, n)
    ccall((:Cudd_addComputeCube, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Ptr{DdNode}}, Ptr{Cint}, Cint), dd, vars, phase, n)
end

function Cudd_CubeArrayToBdd(dd, array)
    ccall((:Cudd_CubeArrayToBdd, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Cint}), dd, array)
end

function Cudd_BddToCubeArray(dd, cube, array)
    ccall((:Cudd_BddToCubeArray, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Cint}), dd, cube, array)
end

function Cudd_FirstNode(dd, f, node)
    ccall((:Cudd_FirstNode, libcudd), Ptr{DdGen}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{DdNode}}), dd, f, node)
end

function Cudd_NextNode(gen, node)
    ccall((:Cudd_NextNode, libcudd), Cint, (Ptr{DdGen}, Ptr{Ptr{DdNode}}), gen, node)
end

function Cudd_GenFree(gen)
    ccall((:Cudd_GenFree, libcudd), Cint, (Ptr{DdGen},), gen)
end

function Cudd_IsGenEmpty(gen)
    ccall((:Cudd_IsGenEmpty, libcudd), Cint, (Ptr{DdGen},), gen)
end

function Cudd_IndicesToCube(dd, array, n)
    ccall((:Cudd_IndicesToCube, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{Cint}, Cint), dd, array, n)
end

function Cudd_PrintVersion(fp)
    ccall((:Cudd_PrintVersion, libcudd), Cvoid, (Ptr{Cint},), fp)
end

function Cudd_AverageDistance(dd)
    ccall((:Cudd_AverageDistance, libcudd), Cdouble, (Ptr{DdManager},), dd)
end

function Cudd_Random(dd)
    ccall((:Cudd_Random, libcudd), Int32, (Ptr{DdManager},), dd)
end

function Cudd_Srandom(dd, seed)
    ccall((:Cudd_Srandom, libcudd), Cvoid, (Ptr{DdManager}, Int32), dd, seed)
end

function Cudd_Density(dd, f, nvars)
    ccall((:Cudd_Density, libcudd), Cdouble, (Ptr{DdManager}, Ptr{DdNode}, Cint), dd, f, nvars)
end

function Cudd_OutOfMem(size)
    ccall((:Cudd_OutOfMem, libcudd), Cvoid, (Cint,), size)
end

function Cudd_OutOfMemSilent(size)
    ccall((:Cudd_OutOfMemSilent, libcudd), Cvoid, (Cint,), size)
end

function Cudd_zddCount(zdd, P)
    ccall((:Cudd_zddCount, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}), zdd, P)
end

function Cudd_zddCountDouble(zdd, P)
    ccall((:Cudd_zddCountDouble, libcudd), Cdouble, (Ptr{DdManager}, Ptr{DdNode}), zdd, P)
end

function Cudd_zddProduct(dd, f, g)
    ccall((:Cudd_zddProduct, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_zddUnateProduct(dd, f, g)
    ccall((:Cudd_zddUnateProduct, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_zddWeakDiv(dd, f, g)
    ccall((:Cudd_zddWeakDiv, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_zddDivide(dd, f, g)
    ccall((:Cudd_zddDivide, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_zddWeakDivF(dd, f, g)
    ccall((:Cudd_zddWeakDivF, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_zddDivideF(dd, f, g)
    ccall((:Cudd_zddDivideF, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g)
end

function Cudd_zddComplement(dd, node)
    ccall((:Cudd_zddComplement, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, node)
end

function Cudd_zddIsop(dd, L, U, zdd_I)
    ccall((:Cudd_zddIsop, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{Ptr{DdNode}}), dd, L, U, zdd_I)
end

function Cudd_bddIsop(dd, L, U)
    ccall((:Cudd_bddIsop, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, L, U)
end

function Cudd_MakeBddFromZddCover(dd, node)
    ccall((:Cudd_MakeBddFromZddCover, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, node)
end

function Cudd_zddDagSize(p_node)
    ccall((:Cudd_zddDagSize, libcudd), Cint, (Ptr{DdNode},), p_node)
end

function Cudd_zddCountMinterm(zdd, node, path)
    ccall((:Cudd_zddCountMinterm, libcudd), Cdouble, (Ptr{DdManager}, Ptr{DdNode}, Cint), zdd, node, path)
end

function Cudd_zddPrintSubtable(table)
    ccall((:Cudd_zddPrintSubtable, libcudd), Cvoid, (Ptr{DdManager},), table)
end

function Cudd_zddPortFromBdd(dd, B)
    ccall((:Cudd_zddPortFromBdd, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, B)
end

function Cudd_zddPortToBdd(dd, f)
    ccall((:Cudd_zddPortToBdd, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_zddReduceHeap(table, heuristic, minsize)
    ccall((:Cudd_zddReduceHeap, libcudd), Cint, (Ptr{DdManager}, Cudd_ReorderingType, Cint), table, heuristic, minsize)
end

function Cudd_zddShuffleHeap(table, permutation)
    ccall((:Cudd_zddShuffleHeap, libcudd), Cint, (Ptr{DdManager}, Ptr{Cint}), table, permutation)
end

function Cudd_zddIte(dd, f, g, h)
    ccall((:Cudd_zddIte, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}, Ptr{DdNode}), dd, f, g, h)
end

function Cudd_zddUnion(dd, P, Q)
    ccall((:Cudd_zddUnion, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, P, Q)
end

function Cudd_zddIntersect(dd, P, Q)
    ccall((:Cudd_zddIntersect, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, P, Q)
end

function Cudd_zddDiff(dd, P, Q)
    ccall((:Cudd_zddDiff, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), dd, P, Q)
end

function Cudd_zddDiffConst(zdd, P, Q)
    ccall((:Cudd_zddDiffConst, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{DdNode}), zdd, P, Q)
end

function Cudd_zddSubset1(dd, P, var)
    ccall((:Cudd_zddSubset1, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint), dd, P, var)
end

function Cudd_zddSubset0(dd, P, var)
    ccall((:Cudd_zddSubset0, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint), dd, P, var)
end

function Cudd_zddChange(dd, P, var)
    ccall((:Cudd_zddChange, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}, Cint), dd, P, var)
end

function Cudd_zddSymmProfile(table, lower, upper)
    ccall((:Cudd_zddSymmProfile, libcudd), Cvoid, (Ptr{DdManager}, Cint, Cint), table, lower, upper)
end

function Cudd_zddPrintMinterm(zdd, node)
    ccall((:Cudd_zddPrintMinterm, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}), zdd, node)
end

function Cudd_zddPrintCover(zdd, node)
    ccall((:Cudd_zddPrintCover, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}), zdd, node)
end

function Cudd_zddPrintDebug(zdd, f, n, pr)
    ccall((:Cudd_zddPrintDebug, libcudd), Cint, (Ptr{DdManager}, Ptr{DdNode}, Cint, Cint), zdd, f, n, pr)
end

function Cudd_zddFirstPath(zdd, f, path)
    ccall((:Cudd_zddFirstPath, libcudd), Ptr{DdGen}, (Ptr{DdManager}, Ptr{DdNode}, Ptr{Ptr{Cint}}), zdd, f, path)
end

function Cudd_zddNextPath(gen, path)
    ccall((:Cudd_zddNextPath, libcudd), Cint, (Ptr{DdGen}, Ptr{Ptr{Cint}}), gen, path)
end

function Cudd_zddCoverPathToString(zdd, path, str)
    ccall((:Cudd_zddCoverPathToString, libcudd), Cstring, (Ptr{DdManager}, Ptr{Cint}, Cstring), zdd, path, str)
end

function Cudd_zddSupport(dd, f)
    ccall((:Cudd_zddSupport, libcudd), Ptr{DdNode}, (Ptr{DdManager}, Ptr{DdNode}), dd, f)
end

function Cudd_zddDumpDot(dd, n, f, inames, onames, fp)
    ccall((:Cudd_zddDumpDot, libcudd), Cint, (Ptr{DdManager}, Cint, Ptr{Ptr{DdNode}}, Ptr{Cstring}, Ptr{Cstring}, Ptr{Cint}), dd, n, f, inames, onames, fp)
end

function Cudd_bddSetPiVar(dd, index)
    ccall((:Cudd_bddSetPiVar, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddSetPsVar(dd, index)
    ccall((:Cudd_bddSetPsVar, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddSetNsVar(dd, index)
    ccall((:Cudd_bddSetNsVar, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddIsPiVar(dd, index)
    ccall((:Cudd_bddIsPiVar, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddIsPsVar(dd, index)
    ccall((:Cudd_bddIsPsVar, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddIsNsVar(dd, index)
    ccall((:Cudd_bddIsNsVar, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddSetPairIndex(dd, index, pairIndex)
    ccall((:Cudd_bddSetPairIndex, libcudd), Cint, (Ptr{DdManager}, Cint, Cint), dd, index, pairIndex)
end

function Cudd_bddReadPairIndex(dd, index)
    ccall((:Cudd_bddReadPairIndex, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddSetVarToBeGrouped(dd, index)
    ccall((:Cudd_bddSetVarToBeGrouped, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddSetVarHardGroup(dd, index)
    ccall((:Cudd_bddSetVarHardGroup, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddResetVarToBeGrouped(dd, index)
    ccall((:Cudd_bddResetVarToBeGrouped, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddIsVarToBeGrouped(dd, index)
    ccall((:Cudd_bddIsVarToBeGrouped, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddSetVarToBeUngrouped(dd, index)
    ccall((:Cudd_bddSetVarToBeUngrouped, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddIsVarToBeUngrouped(dd, index)
    ccall((:Cudd_bddIsVarToBeUngrouped, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end

function Cudd_bddIsVarHardGroup(dd, index)
    ccall((:Cudd_bddIsVarHardGroup, libcudd), Cint, (Ptr{DdManager}, Cint), dd, index)
end
