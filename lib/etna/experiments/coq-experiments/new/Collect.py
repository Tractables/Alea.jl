import argparse
import json
import os
import sys

# Get the directory of the current script.
script_dir = os.path.dirname(os.path.realpath(__file__))
# Construct the path to the 'tool' directory, which is three levels up from the script's directory.
tool_path = os.path.abspath(os.path.join(script_dir, '..', '..', '..', 'tool'))
# Prepend the 'tool' directory to sys.path to ensure our local 'benchtool' is imported.
sys.path.insert(0, tool_path)

from benchtool.Coq import Coq
from benchtool.Types import TrialConfig, ReplaceLevel


def collect(results: str):
    tool = Coq(results=results, replace_level=ReplaceLevel.SKIP)

    for workload in tool.all_workloads():
        print(f"\033[91m{workload.name}\033[0m")

        print(f"\033[91m preprocessing {workload.name}\033[0m")
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
                    run_trial(cfg)


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--data', help='path to folder for JSON data')
    args = p.parse_args()

    print(f"CWD: {os.getcwd()}")

    results_path = f'{os.getcwd()}/{args.data}'
    collect(results_path)
