#!/bin/bash
# Usage:  ./fuzz_driver mut_low mut_high run_low run_high successes discards 
# Common: ./fuzz_driver 1 19 0 20 10000000 10000000
for run in `seq $3 $4`; do
  for i in `seq $1 $2`; do
    echo "Fuzzing mutant #: $i"
    cp Bench.v Tmp.v
    echo "Extract Constant defNumTests => \"$5\"." >> Tmp.v
    echo "Extract Constant defNumDiscards => \"$6\"." >> Tmp.v

    echo "Definition qcfSSNI_copy_prop_$i :=" >> Tmp.v
    echo "  fun v => propSSNI_helper (nth_table $i) v exp_result_opt_bool." >> Tmp.v
    echo "Definition qcfSSNI_copy_loop_$i :=" >> Tmp.v 
    echo "  fun (_ : unit) => fuzzLoop (resize 3 gen_variation_copy) fuzz (fun _ => es) qcfSSNI_copy_prop_$i." >> Tmp.v
    echo "FuzzQC qcfSSNI_copy_prop_$i (qcfSSNI_copy_loop_$i tt)." >> Tmp.v

    coqc -R . IFC Tmp.v &> output/fuzz_$5-$i-$run.out
 
    sleep 2
  done
done


