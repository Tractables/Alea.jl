import argparse
from benchtool.Analysis import *
from benchtool.Plot import *
from functools import partial


def analyze(results: str, images: str):
    df = parse_results(results)

    if not os.path.exists(images):
        os.makedirs(images)

    # Generate task bucket charts used in Figure 3.

    # strategies, colors = zip(*[
    #     ('BespokeGenerator', '#000'),
    #     ('New57_60_59_74_67Generator', "#005"),
    #     # ('UniformAppsGenerator', '#005'),
    #     # ('EntropyApproxAndUniformAppsGenerator', '#303'),
    #     # ('EntropyApproxGenerator', '#500'),
    #     # ('Apps4321Generator', '#050'),
    #     ('TypeBasedGenerator', '#033'),
    #     ('ManualTypeBasedGenerator', '#033'),
    #     ('Tuned1TypeBasedGenerator', '#033'),
    # ])
    # colors = list(reversed(colors))

    strategies = [
                        'TypeBasedGenerator',
                        'BespokeGenerator',
                        'ManualTypeBasedGenerator',
        ]

    for workload in ['IFC']:
        tbl = df.groupby(['workload', 'strategy', 'task'], as_index=False).agg({"time": "max"})
        tbl.to_csv(f'{images}/{workload}_medians.csv')
        times = partial(stacked_barchart_times, case=workload, df=df)
        times(
            strategies=strategies,
            # colors=colors,
            limits=[0.1, 1, 10, 60],
            limit_type='time',
            image_path=images,
            show=False,
        )


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument('--data', help='path to folder for JSON data')
    p.add_argument('--figures', help='path to folder for figures')
    args = p.parse_args()

    results_path = f'{os.getcwd()}/{args.data}'
    images_path = f'{os.getcwd()}/{args.figures}'
    analyze(results_path, images_path)
