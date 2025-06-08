import argparse
import json
import os
import sys
import multiprocessing
from typing import Callable

# Get the directory of the current script.
script_dir = os.path.dirname(os.path.realpath(__file__))
# Construct the path to the 'tool' directory, which is three levels up from the script's directory.
tool_path = os.path.abspath(os.path.join(script_dir, '..', '..', '..', 'tool'))
# Prepend the 'tool' directory to sys.path to ensure our local 'benchtool' is imported.
sys.path.insert(0, tool_path)

from benchtool.Coq import Coq
from benchtool.Types import TrialConfig, ReplaceLevel


def run_process_trial(trial_func: Callable, cfg: TrialConfig) -> None:
    """Run a trial in a separate process."""
    try:
        result = trial_func(cfg)
        return result
    except Exception as e:
        print(f"Error in process running trial: {e}")
        raise

def collect(results: str):
    tool = Coq(results=results, replace_level=ReplaceLevel.SKIP)

    # for workload in ["BST", "RBT", "STLC"]:
    for workload in tool.all_workloads():
        if workload.name not in ["BST", "RBT", "STLC"]:
            continue
        print(f"\033[91m{workload.name}\033[0m")

        # print(f"\033[91m preprocessing {workload.name}\033[0m")
        tool._preprocess(workload)

        tasks_json = json.load(open(f'experiments/coq-experiments/5.1/{workload.name}_tasks.json'))

        for variant in tool.all_variants(workload):

            if variant.name == 'base':
                continue

            run_trial = None

            # target_strategies = [
            #     "TypeBasedGenerator",
            #     "STLCTypeBasedInitialGenerator",
            #     "STLCTypeBasedTrainedGenerator",
            #     "BespokeGenerator",
            #     "STLCBespokeInitialGenerator",
            #     "STLCBespokeTrainedGenerator",
            # ]
            # for s in target_strategies:
            #     if not any(
            #         strategy.name == s
            #         for strategy in tool.all_strategies(workload)
            #     ):
            #         print(f"Missing strategy {s}")
            #         print(tool.all_strategies(workload))
            #         exit(1)

            SKIP = True
            # for strategy in tool.all_strategies(workload):
            #     if SKIP and strategy.name not in target_strategies:
            #         print(f"Skipping {strategy.name}")
            for strategy in tool.all_strategies(workload):
                # if SKIP and strategy.name not in target_strategies:
                #     continue

                processes = []
                for property in tool.all_properties(workload):
                    property = 'test_' + property
                    if tasks_json['tasks'] and property not in tasks_json['tasks'][variant.name]:
                        continue

                    # Don't compile tasks that are already completed.
                    finished = set(os.listdir(results))
                    file = f'{workload.name},{strategy.name},{variant.name},{property}'
                    if f'{file}.json' in finished:
                        continue

                    if not run_trial:
                        run_trial = tool.apply_variant(workload, variant, no_base=True)

                    cfg = TrialConfig(workload=workload,
                                      strategy=strategy.name,
                                      property=property,
                                      trials=11,
                                      timeout=60,
                                      short_circuit=False)
                    
                    p = multiprocessing.Process(
                        target=run_process_trial,
                        args=(run_trial, cfg)
                    )
                    processes.append(p)
                    p.start()

                # Wait for all processes to complete
                for p in processes:
                    p.join()
                print(f"All trials completed for workload={workload.name}, variant={variant.name}, strategy={strategy.name}")


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--data', help='path to folder for JSON data')
    args = p.parse_args()

    print(f"CWD: {os.getcwd()}")

    results_path = f'{os.getcwd()}/{args.data}'
    collect(results_path)
