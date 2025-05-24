coqtop -R . IFC < <(cat Strategies/TypeBasedGenerator.v && echo "Print GenSizedBinOpT.")
coqtop -R . IFC < <(cat Strategies/TypeBasedGenerator.v && echo "Print GenSizedInstr.")
coqtop -R . IFC < <(cat Strategies/TypeBasedGenerator.v && echo "Print GenSizedPointer.")
coqtop -R . IFC < <(cat Strategies/TypeBasedGenerator.v && echo "Print GenSizedValue.")
coqtop -R . IFC < <(cat Strategies/TypeBasedGenerator.v && echo "Print GenSizedAtom.")
coqtop -R . IFC < <(cat Strategies/TypeBasedGenerator.v && echo "Print GenSizedPtr_atom.")
coqtop -R . IFC < <(cat Strategies/TypeBasedGenerator.v && echo "Print GenSizedStackFrame.")
coqtop -R . IFC < <(cat Strategies/TypeBasedGenerator.v && echo "Print GenSizedStack.")
coqtop -R . IFC < <(cat Strategies/TypeBasedGenerator.v && echo "Print GenSizedSState.")
coqtop -R . IFC < <(cat Strategies/TypeBasedGenerator.v && echo "Print GenSizedVariation.")

coqtop -R . IFC < <(cat Strategies/TypeBasedGenerator.v && echo "Print GenSizedBinOpT.")

coqtop -R . IFC < <(cat Strategies/TypeBasedGenerator.v && echo "Print Map.GenSizedt.")
