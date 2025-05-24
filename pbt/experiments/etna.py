#!/usr/bin/env python3

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

if __name__ == "__main__":
    copy_generators()