for i in `seq $1 $2`; do
  echo "Testing Mutant $i.."
  cp Bench.v Tmp.v
  echo "QuickChick (testMutantX_ rSSNI_$3 $i)." >> Tmp.v 
  coqc -R . IFC Tmp.v &> output/output_rand_$3_$i.out
  sleep 2
done

