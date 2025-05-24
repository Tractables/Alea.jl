#!/usr/bin/env python3


# opam setups
# opam switch create 4.10.0+af

# $ ls experiments-output/generators 
# BSTTypeBasedInitialGenerator.v  RBTTypeBasedInitialGenerator.v  STLCBespokeInitialGenerator.v   STLCTypeBasedInitialGenerator.v
# BSTTypeBasedTrainedGenerator.v  RBTTypeBasedTrainedGenerator.v  STLCBespokeTrainedGenerator.v   STLCTypeBasedTrainedGenerator.v
# [q14]~/g/test/Dice.jl
# $ ls etna/workloads/Coq/STLC/Strategies 
# BespokeGenerator.v   TypeBasedGenerator.v
# Copy each generator to the corresponding Strategies directory in etna/workloads/Coq/

import os
import shutil

workload_to_generators = {
    "BST": ["BSTTypeBasedInitialGenerator.v", "BSTTypeBasedTrainedGenerator.v"],
    "RBT": ["RBTTypeBasedInitialGenerator.v", "RBTTypeBasedTrainedGenerator.v"],
    "STLC": ["STLCBespokeInitialGenerator.v", "STLCBespokeTrainedGenerator.v", "STLCTypeBasedInitialGenerator.v", "STLCTypeBasedTrainedGenerator.v"]
}

def copy_generators():
    # Define the source and destination directories
    source_dir = "experiments-output/generators"
    destination_dir = "etna/workloads/Coq"

    # Create the destination directory if it doesn't exist
    os.makedirs(destination_dir, exist_ok=True)

    # Copy each generator to the corresponding Strategies directory in etna/workloads/Coq/
    for workload, generators in workload_to_generators.items():
        for generator in generators:
            # if generator doesn't exist, error
            if not os.path.exists(os.path.join(source_dir, generator)):
                raise FileNotFoundError(f"Generator {generator} not found in {source_dir}")

            shutil.copy2(os.path.join(source_dir, generator), os.path.join(destination_dir, workload, "Strategies", generator))
    
    # cd to etna
    os.chdir("etna")
    os.system("python3 qc-checker.py use_new_qc")
    # if fails, exit
    if os.system("python3 qc-checker.py use_new_qc") != 0:
        print("Failed to run qc-checker.py use_new_qc")
        exit(1)
    os.system("python3 bounds-switch.py to_max")
    # mkdir etna/data/artifact
    os.makedirs("data/artifact", exist_ok=True)
    os.system("python3 experiments/coq-experiments/new/Collect.py --data=data/artifact")

if __name__ == "__main__":
    copy_generators()