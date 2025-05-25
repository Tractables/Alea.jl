CUDD.jl
=======

[![Build Status](https://github.com/sisl/CUDD.jl/workflows/CI/badge.svg)](https://github.com/sisl/CUDD.jl/actions)
[![codecov](https://codecov.io/gh/sisl/CUDD.jl/branch/master/graph/badge.svg?token=HE8R1IljBV)](https://codecov.io/gh/sisl/CUDD.jl)

A Julia wrapper for the [CUDD](https://github.com/ivmai/cudd)
C library to manipulate Algebraic Decision Diagrams (ADDs) and Binary Decision Diagrams (BDDs).


Basic usage:
```julia
>>> using CUDD
>>> manager = initialize_cudd()
>>> x1 = add_var(manager)
>>> ref(x1)
>>> x2 = add_var(manager)
>>> ref(x2)
>>> f = add_apply(manager, add_plus_c, x1, x2)
>>> get_value(evaluate(manager, f, Cint[1, 1]))
2.0
```

For further examples, see the Julia notebook in the ``docs`` folder.

Installation
-----

```julia
using Pkg; Pkg.add("CUDD")
```

License
-------

This code is licensed under the MIT license.  See LICENSE for details.

