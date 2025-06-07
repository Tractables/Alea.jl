#!/usr/bin/env python3

import argparse
import os
import shutil
import subprocess
import sys
# notes for later:
# opam setups
# opam switch create 4.10.0+afl
# opam pin coq 8.15.2


workload_to_generators = {
    "BST": ["BSTTypeBasedInitialGenerator.v", "BSTTypeBasedTrainedGenerator.v"],
    "RBT": ["RBTTypeBasedInitialGenerator.v", "RBTTypeBasedTrainedGenerator.v"],
    "STLC": ["STLCBespokeInitialGenerator.v", "STLCBespokeTrainedGenerator.v", "STLCTypeBasedInitialGenerator.v", "STLCTypeBasedTrainedGenerator.v"]
}

def copy_generators():
    # Define the source and destination directories
    source_dir = "experiments-output/generators"
    destination_dir = "lib/etna/workloads/Coq"

    # Create the destination directory if it doesn't exist
    os.makedirs(destination_dir, exist_ok=True)

    # Copy each generator to the corresponding Strategies directory in etna/workloads/Coq/
    for workload, generators in workload_to_generators.items():
        for generator in generators:
            destination_path = os.path.join(destination_dir, workload, "Strategies", generator)
            if os.path.exists(destination_path):
                print(f"Generator {generator} already exists in {destination_path}")
                continue

            # if generator doesn't exist, error
            if not os.path.exists(os.path.join(source_dir, generator)):
                raise FileNotFoundError(f"Generator {generator} not found in {source_dir}")

            shutil.copy2(os.path.join(source_dir, generator), os.path.join(destination_dir, workload, "Strategies", generator))

def run_command(command: str, cwd: str = None):
    if args.verbose:
        # print command in color
        print(f"\033[94m{command}\033[0m")
    
    result = subprocess.run(command, shell=True, cwd=cwd)

    if result.returncode != 0:
        print(f"Failed to run {command}")
        exit(1)

def run_etna(args: argparse.Namespace):
    etna_dir = "lib/etna"
    run_command("python3 qc-checker.py use_new_qc", cwd=etna_dir)
    run_command("python3 bounds-switch.py to_max", cwd=etna_dir)


    run_command("python3 experiments/coq-experiments/new/Collect.py --data=data-artifact", cwd=etna_dir)

    # from lib/etna/workloads/Coq/<workload>, run coq_makefile -f _CoqProject -o Makefile && make
    for workload in workload_to_generators.keys():
        workload_dir = os.path.join(etna_dir, "workloads", "Coq", workload)
        run_command("coq_makefile -f _CoqProject -o Makefile && make", cwd=workload_dir)

    run_command("python3 experiments/coq-experiments/new/Collect.py --data=data-artifact", cwd=etna_dir)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()
    copy_generators()
    run_etna(args)