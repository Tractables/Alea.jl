import argparse
from benchtool.Analysis import *
from benchtool.Plot import *


def analyze(results: str, original: str):
    dfsc = parse_results(original)
    dfsc = dfsc[(dfsc['strategy'] == 'Small') & (dfsc['workload'].isin(['BST', 'RBT']))]

    df = parse_results(results)
    df = pd.concat([df, dfsc])
    df['foundbug'] = df['foundbug'] & (df['time'] < 60)

    smallonly = solved_by_one(df, 'Small', 'SmallRev')
    print('Number of tasks solved by SmallCheck in original order but not reversed order:')
    print(len(smallonly))

    revonly = solved_by_one(df, 'SmallRev', 'Small')
    print('Number of tasks solved by SmallCheck in reversed order but not original order:')
    print(len(revonly))

    print('Times to failure for these tasks:')
    dfrev = df[(df['strategy'] == 'SmallRev') & (df['task'].isin(revonly))]
    print(dfrev[['strategy', 'task', 'time']])


def solved_by(df, strategy: str):
    df = df.groupby(['workload', 'strategy', 'task'], as_index=False).agg({'foundbug': 'all'})
    return list(df[(df['strategy'] == strategy) & df['foundbug']]['task'])


def solved_by_one(df, strat1: str, strat2: str):
    return [t for t in solved_by(df, strat1) if t not in solved_by(df, strat2)]


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument('--data', help='path to folder for JSON data')
    p.add_argument('--original', help='path to folder for JSON data (original SmallCheck results)')
    args = p.parse_args()

    results_path = f'{os.getcwd()}/{args.data}'
    original_path = f'{os.getcwd()}/{args.original}'
    analyze(results_path, original_path)