import argparse
import json
import os

from benchtool.Coq import Coq
from benchtool.Types import TrialConfig, ReplaceLevel


def collect(results: str):
    tool = Coq(results=results, replace_level=ReplaceLevel.SKIP)

    for workload in tool.all_workloads():
        if workload.name not in ['BST', 'RBT', 'STLC']:
            continue

        tool._preprocess(workload)

        tasks_json = json.load(open(f'experiments/coq-experiments/5.1/{workload.name}_tasks.json'))

        for variant in tool.all_variants(workload):

            if variant.name == 'base':
                continue

            run_trial = None

            for strategy in tool.all_strategies(workload):
                if strategy.name not in [
                    'BespokeGenerator',
                    'EntropyApproxGenerator',
                    'EntropyApproxAndUniformAppsGenerator',
                    'UniformAppsGenerator'
                    'Apps4321Generator'
                ]:
                    continue

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
                                      trials=10,
                                      timeout=60,
                                      short_circuit=True)
                    run_trial(cfg)


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--data', help='path to folder for JSON data')
    args = p.parse_args()

    results_path = f'{os.getcwd()}/{args.data}'
    collect(results_path)
