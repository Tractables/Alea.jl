import argparse
from benchtool.Analysis import *
from benchtool.Plot import *
from functools import partial


workload_to_charts = {
    "BST": [
        Chart(
            name="BST Type-Based",
            generators=(
                Generator(filename="TypeBasedGenerator.v", name="Etna", is_baseline=True),
                Generator(filename="BSTTypeBasedInitialGenerator.v", name="Initial", is_baseline=True),
                Generator(filename="BSTTypeBasedTrainedGenerator.v", name="Trained", is_baseline=False),
            )
        ),
    ],
    "RBT": [
        Chart(
            name="RBT Type-Based",
            generators=(
                Generator(filename="TypeBasedGenerator.v", name="Etna", is_baseline=True),
                Generator(filename="RBTTypeBasedInitialGenerator.v", name="Initial", is_baseline=True),
                Generator(filename="RBTTypeBasedTrainedGenerator.v", name="Trained", is_baseline=False),
            )
        ),
    ],
    "STLC": [
        Chart(
            name="STLC Type-Based",
            generators=(
                Generator(filename="TypeBasedGenerator.v", name="Etna", is_baseline=True),
                Generator(filename="STLCTypeBasedInitialGenerator.v", name="Initial", is_baseline=True),
                Generator(filename="STLCTypeBasedTrainedGenerator.v", name="Trained", is_baseline=False),
            )
        ),
        Chart(
            name="STLC Bespoke",
            generators=(
                Generator(filename="BespokeGenerator.v", name="Etna", is_baseline=True),
                Generator(filename="STLCBespokeInitialGenerator.v", name="Initial", is_baseline=True),
                Generator(filename="STLCBespokeTrainedGenerator.v", name="Trained", is_baseline=False),
            )
        ),
    ],
}


def analyze(results: str, images: str):
    df = parse_results(results)

    if not os.path.exists(images):
        os.makedirs(images)

    # Generate task bucket charts used in Figure 3.

    for workload, charts in workload_to_charts.items():
        times = partial(stacked_barchart_times, df=df)
        for chart in charts:
            times(
                chart=chart,
                limits=[0.1, 1, 10, 60],
                limit_type='time',
                image_path=images,
                show=False,
                workload=workload,
            )


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument('--data', help='path to folder for JSON data')
    p.add_argument('--figures', help='path to folder for figures')
    args = p.parse_args()

    results_path = f'{os.getcwd()}/{args.data}'
    images_path = f'{os.getcwd()}/{args.figures}'
    analyze(results_path, images_path)
