import argparse
from benchtool.Analysis import *
from benchtool.Plot import *
from functools import partial


def analyze(results: str, original: str, images: str):
    workloads = ['BST', 'RBT', 'STLC']

    dforig = parse_results(original)
    dforig = dforig[(dforig['strategy'] == 'TypeBasedFuzzer') &
                    (dforig['workload'].isin(workloads))]
    dforig['strategy'] = 'Tuned TypeBasedFuzzer'

    df = parse_results(results)
    df['strategy'] = 'Original TypeBasedFuzzer'
    df = pd.concat([df, dforig])

    if not os.path.exists(images):
        os.makedirs(images)

    # Generate task bucket charts used in Figure 5.
    for workload in workloads:
        times = partial(stacked_barchart_times, case=workload, df=df)
        times(
            strategies=['Original TypeBasedFuzzer', 'Tuned TypeBasedFuzzer'],
            colors=['#DC5F00', '#DC5F00'],
            limits=[0.1, 1, 10, 60],
            limit_type='time',
            image_path=images,
            show=False,
        )


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument('--data', help='path to folder for JSON data')
    p.add_argument('--original', help='path to folder for JSON data (for original FuzzChick)')
    p.add_argument('--figures', help='path to folder for figures')
    args = p.parse_args()

    results_path = f'{os.getcwd()}/{args.data}'
    original_path = f'{os.getcwd()}/{args.original}'
    images_path = f'{os.getcwd()}/{args.figures}'
    analyze(results_path, original_path, images_path)
