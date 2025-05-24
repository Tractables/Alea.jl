for i in `seq $1 $2`; do
  echo "Testing Mutant $i.."
  cp Bench.v Tmp.v
  echo "Definition qcfSSNI_copy_prop_$i :=" >> Tmp.v
  echo "  fun v => propSSNI_helper (nth_table $i) v exp_result_opt_bool." >> Tmp.v
  echo "Definition qcfSSNI_copy_loop_$i :=" >> Tmp.v 
  echo "  fun (_ : unit) => fuzzLoop (resize 3 gen_variation_copy) fuzz (fun _ => es) qcfSSNI_copy_prop_$i." >> Tmp.v
  echo "FuzzQC qcfSSNI_copy_prop_$i (qcfSSNI_copy_loop_$i tt)." >> Tmp.v
  coqc -R . IFC Tmp.v &> output/output_qcfuzz_$i.out
  sleep 2
done

