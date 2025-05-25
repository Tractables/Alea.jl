import argparse
import os

from benchtool.Haskell import Haskell
from benchtool.Types import ReplaceLevel, TrialConfig
from benchtool.Tasks import tasks

# Section 4.3 (Enumerator Sensitivity)


def collect(results: str):
    tool = Haskell(results, replace_level=ReplaceLevel.SKIP)

    for workload in tool.all_workloads():
        if workload.name not in ['BST', 'RBT']:
            continue

        for variant in tool.all_variants(workload):
            if variant.name == 'base':
                continue

            run_trial = None

            for strategy in tool.all_strategies(workload):
                if strategy.name != 'SmallRev':
                    continue

                for property in tool.all_properties(workload):
                    if workload.name in ['BST', 'RBT']:
                        if property.split('_')[1] not in tasks[workload.name][variant.name]:
                            continue

                    # TO SAVE TIME:
                    # Run only 1 trial for deterministic strategies
                    trials = 1

                    # Don't compile tasks that are already completed.
                    finished = set(os.listdir(results))
                    file = f'{workload.name},{strategy.name},{variant.name},{property}'
                    if f'{file}.json' in finished:
                        continue

                    if not run_trial:
                        run_trial = tool.apply_variant(workload, variant)

                    cfg = TrialConfig(workload=workload,
                                      strategy=strategy.name,
                                      property=property,
                                      trials=trials,
                                      timeout=65,
                                      short_circuit=True)

                    run_trial(cfg)


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--data', help='path to folder for JSON data')
    args = p.parse_args()

    results_path = f'{os.getcwd()}/{args.data}'
    collect(results_path)
