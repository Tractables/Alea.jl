import argparse
import plotly.express as px
from benchtool.Analysis import *
from Tasks import special


def analyze(results: str, images: str):
    df = parse_results(results)

    df['size'] = df['strategy'].str[-2:]
    df['size'] = df['size'].astype(int)
    df = df[['task', 'size', 'inputs', 'time']]

    df = df.groupby(['task', 'size'], as_index=False).agg({'inputs': 'mean', 'time': 'mean'})

    colors = {special[0]: 'red', special[1]: 'green', special[2]: 'blue'}
    color_map = {
        task: colors[task] if task in special else 'lightgray' for task in df['task'].unique()
    }

    if not os.path.exists(images):
        os.makedirs(images)

    fig = px.line(df,
                  x='size',
                  y='inputs',
                  color='task',
                  color_discrete_map=color_map,
                  category_orders={'task': special})

    fig.data = fig.data[::-1]
    fig.update_layout(xaxis_title='size of tree', yaxis_title='inputs to failure', showlegend=False)
    fig.update_layout(font={'family': 'Helvetica', 'size': 50}, width=1500, height=1200)
    fig.update_layout(xaxis=dict(tickmode='linear', tick0=3, dtick=3))
    fig.update_layout(yaxis=dict(tickmode='linear', dtick=200))

    fig.write_image(f'{images}/fig2.png')


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument('--data', help='path to folder for JSON data')
    p.add_argument('--figures', help='path to folder for figures')
    args = p.parse_args()

    results_path = f'{os.getcwd()}/{args.data}'
    images_path = f'{os.getcwd()}/{args.figures}'
    analyze(results_path, images_path)