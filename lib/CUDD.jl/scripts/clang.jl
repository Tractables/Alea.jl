# Inspired from https://github.com/jump-dev/Clp.jl/blob/master/scripts/clang.jl written by Oscar Downson (@odow).
#
# This script can be used to build the C interface to CUDD. However, it requires
# you to manually do the following steps first:
#
# 1) Copy `cudd/cudd.h` from CUDD into this /scripts directory
# 2) Run this script

import Clang

LIBCUDD_HEADERS = [
    joinpath(@__DIR__, "cudd.h"),
]

wc = Clang.init(
    headers = LIBCUDD_HEADERS,
    output_file = joinpath(dirname(@__DIR__), "src", "gen", "libcudd_api.jl"),
    common_file = joinpath(dirname(@__DIR__), "src", "gen", "libcudd_common.jl"),
    header_wrapped = (root, current) -> root == current,
    header_library = x -> "libcudd",
    clang_diagnostics = true,
)

run(wc)
