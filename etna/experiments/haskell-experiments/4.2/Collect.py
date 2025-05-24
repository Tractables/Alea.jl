import argparse
import os

from benchtool.Haskell import Haskell
from benchtool.Types import ReplaceLevel, TrialConfig
from benchtool.Tasks import tasks
from Tasks import special

# Section 4.2 (Exploring Size Generation)


def collect(results: str):
    tool = Haskell(results, replace_level=ReplaceLevel.SKIP)

    for workload in tool.all_workloads():
        if workload.name != 'BST':
            continue

        for variant in tool.all_variants(workload):
            if variant.name == 'base':
                continue

            run_trial = None

            for strategy in tool.all_strategies(workload):
                if strategy.name != 'Size':
                    continue

                for property in tool.all_properties(workload):
                    if property.split('_')[1] not in tasks[workload.name][variant.name]:
                        continue

                    # TO SAVE TIME:
                    # Run only 10 trials on tasks other than the three "special"
                    # tasks discussed in the analysis.
                    task = f'{workload.name},{variant.name},{property}'
                    trials = 100 if task in special else 10

                    for size in range(3, 31, 3):
                        # Vary size of tree from 3 to 30 nodes, at increments of 3.
                        os.environ['BSTSIZE'] = str(size)

                        file = f'{size:02},{workload.name},{strategy.name},{variant.name},{property}'

                        # Don't compile tasks that are already completed.
                        finished = set(os.listdir(results))
                        if f'{file}.json' in finished:
                            continue

                        if not run_trial:
                            run_trial = tool.apply_variant(workload, variant)

                        cfg = TrialConfig(workload=workload,
                                          strategy=strategy.name,
                                          property=property,
                                          label=f'{strategy.name}{size:02}',
                                          trials=trials,
                                          timeout=65,
                                          file=file)
                        run_trial(cfg)


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--data', help='path to folder for JSON data')
    args = p.parse_args()

    results_path = f'{os.getcwd()}/{args.data}'
    collect(results_path)
