#!/usr/bin/env python3
import sys
import subprocess

# Check if running inside Docker by looking for /.dockerenv
import os

if not os.path.exists("/.dockerenv"):
    print("Error: This script must be run inside a Docker container.", file=sys.stderr)
    sys.exit(1)


def main():
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('--verbose', action='store_true', help='Enable verbose output')
    args = parser.parse_args()
    verbose_flag = "--verbose" if args.verbose else ""

    run_args = ["./scripts/run.py", "--all", "--parallel"]
    if verbose_flag:
        run_args.append(verbose_flag)
    subprocess.run(run_args, check=True)

    etna_args = ["./scripts/etna.py"]
    if verbose_flag:
        etna_args.append(verbose_flag)
    subprocess.run(etna_args, check=True)

if __name__ == "__main__":
    main()