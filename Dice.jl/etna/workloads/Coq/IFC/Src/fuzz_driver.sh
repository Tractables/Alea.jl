#!/bin/bash
# Usage:  ./fuzz_driver per_run total 
for run in `seq 0 $2`; do
  export LOW=$(expr $run \* $1)
  export HI=$(expr $run \* $1 + $1 - 1)
  echo $LOW
  echo $HI
  echo './fuzz_driver_one_run.sh 0 32 $LOW $HI 1000 10000 $MODE'
  screen -S run$run -dm bash -c './fuzz_driver_one_run.sh 0 32 $LOW $HI 1000 10000'
  sleep 2
done
