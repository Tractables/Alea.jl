# This is significantly more time consuming than the other three workloads
# combined, so we separate it out in case the user wants to run these two
# scripts separately.

import argparse
import os

from benchtool.Coq import Coq
from benchtool.Types import TrialConfig, ReplaceLevel


def collect(results: str):
    tool = Coq(results=results, replace_level=ReplaceLevel.SKIP)

    for workload in tool.all_workloads():
        if workload.name != 'IFC':
            continue

        tool._preprocess(workload)

        for variant in tool.all_variants(workload):

            if variant.name == 'base':
                continue

            if variant.name in ['OpBRet_8', 'OpBRet_9', 'OpWrite_8', 'OpWrite_9']:
                continue

            run_trial = None

            for strategy in tool.all_strategies(workload):
                if strategy.name not in [
                        'TypeBasedGenerator',
                        'BespokeGenerator',
                        'ManualTypeBasedGenerator',
                        # 'TypeBasedFuzzer',
                        # 'VariationalFuzzer'  # Only for this workload
                ]:
                    continue

                property = 'test_propSSNI_smart'

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
