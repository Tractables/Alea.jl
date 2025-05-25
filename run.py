#!/usr/bin/env python3
"""
Script to run experiments and generate distribution plots.

This script runs experiments with different configurations and generates bar charts
comparing initial, trained, and target distributions. It supports:

1. Multiple experiment types:
   - RBT Type-Based (Uniform/Linear)
   - STLC Type-Based (Uniform/Linear)
   - STLC Bespoke (Uniform/Linear)

2. Command line arguments:
   --verbose: Print detailed file paths
   --parallel: Run experiments in parallel
   --all: Run all figures
   --fig2: Run figure 2 experiments
   --fig3: Run figure 3 experiment
   --fast: Use faster training settings
   --fig2-learning-rate: Learning rate for figure 2
   --fig2-epochs: Epochs for figure 2
   --fig3-learning-rate: Learning rate for figure 3
   --fig3-epochs: Epochs for figure 3
"""

"""
Setup:
julia --project -e "import Pkg;Pkg.add(url=\"https://github.com/PoorvaGarg/IRTools.jl.git\",rev=\"loop-break-patch\")"
julia --project -e "import Pkg;Pkg.add(url=\"https://github.com/rtjoa/CUDD.jl.git\",rev=\"m1compat\")"
julia --project -e "import Pkg;Pkg.instantiate()"
"""

import subprocess
import re
import pandas as pd
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import matplotlib.pyplot as plt
import os
import sys
import argparse
import multiprocessing
from functools import partial
import glob
import shutil
from typing import List, Dict, Any, Optional, Callable
from dataclasses import dataclass


@dataclass
class TrainingRun:
    command: List[str]

@dataclass
class TrainingResult:
    log_path: str
@dataclass
class Experiment:
    training_runs: Dict[str, TrainingRun]

empty_experiment = Experiment(training_runs={})

@dataclass
class ExperimentResult:
    training_results: Dict[str, TrainingResult]

@dataclass
class Config:
    output_dir: str
    args: argparse.Namespace

@dataclass
class TargetDistribution:
    name: str
    val_to_prob: Callable[[int], float] # val -> prob (non-normalized)

def run_training_run(config: Config, run: TrainingRun) -> TrainingResult:
    """Run a Julia command and return the log file path."""

    if not config.args.force:
        existing_log_path = run_tool(config, run.command + ["-l"]).log_path
        if os.path.exists(existing_log_path):
            print(f"Using existing log path: {existing_log_path}")
            return TrainingResult(existing_log_path)

    result = run_tool(config, run.command)

    if config.args.verbose:
        print(f"Log file path: {result.log_path}")

    return result

def run_tool(config: Config, command: List[str]) -> TrainingResult:
    if config.args.verbose:
        print(f"Running command: {' '.join(command)}")

    result = subprocess.run(command, capture_output=True, text=True)
    if result.returncode != 0:
        print("Error: Command failed with status", result.returncode)
        print("stdout:", result.stdout)
        print("stderr:", result.stderr)
        sys.exit(1)
    
    log_match = re.search(r'Logging to (.*?)\n', result.stdout)
    if not log_match:
        print("Error: Could not find log file path in output")
        print("stdout:", result.stdout)
        sys.exit(1)
 
    return TrainingResult(log_match.group(1))

def run_experiments_parallel(config: Config, experiments: List[Experiment]) -> List[ExperimentResult]:
    experiment_results = [ ExperimentResult({}) for _ in experiments ]
    
    # Create jobs with just the necessary arguments
    jobs = []
    job_indices = []  # Keep track of which experiment and key each job belongs to
    for i, experiment in enumerate(experiments):
        for key, training_run in experiment.training_runs.items():
            jobs.append((config, training_run))
            job_indices.append((i, key))
    
    # Run jobs in parallel
    num_workers = min(len(jobs), multiprocessing.cpu_count())
    pool = multiprocessing.Pool(processes=num_workers)
    job_results = pool.starmap(run_training_run, jobs)
    
    # Map results back to their experiments
    for (i, key), result in zip(job_indices, job_results):
        experiment_results[i].training_results[key] = result
    
    return experiment_results

def run_experiments_sequential(config: Config, experiments: List[Experiment]) -> List[ExperimentResult]:
    """Run experiments sequentially and return log paths."""
    return [ExperimentResult({
        key: run_training_run(config, training_run)
        for key, training_run in experiment.training_runs.items()
    }) for experiment in experiments]

def extract(path: str, pattern: str):
    """Parse initial and trained distribution paths from the log file."""
    with open(path, 'r') as f:
        contents = f.read()

    match = re.search(pattern, contents)
    if match is None or len(match.groups()) != 1:
        print(f"Error: Expected 1 group, got {match} (pattern: {pattern}, path: {path})")
        sys.exit(1)
    
    return match.group(1)

def get_target_distribution(initial_dist: pd.DataFrame, target_dist: TargetDistribution) -> pd.DataFrame:
    """Calculate target distribution based on type."""
    max_val = max(initial_dist['val'])
    probs = [target_dist.val_to_prob(val) for val in initial_dist['val']]
    total = sum(probs)
    probs = [p/total for p in probs]
    
    return pd.DataFrame({
        'val': initial_dist['val'],
        'probability': probs
    })

def plot_distributions(initial_dist: pd.DataFrame, trained_dist: pd.DataFrame, 
                     output_path: str, td: TargetDistribution, exp_name: str = '') -> None:
    """Plot initial and trained distributions as a bar chart."""
    plt.figure(figsize=(10, 6))
    
    x = initial_dist['val']
    width = 0.25
    
    trained_color = '#1E88E5'  # blue!70!cyan
    initial_color = '#FF3333'  # red!80!white
    
    target_dist = get_target_distribution(initial_dist, td)
    
    plt.bar(x - width, initial_dist['probability'], width, label='Initial', alpha=0.7, color=initial_color)
    plt.bar(x, trained_dist['probability'], width, label='Trained', alpha=0.7, color=trained_color)
    plt.bar(x + width, target_dist['probability'], width, label='Target', 
            color='white', edgecolor='black', hatch='///', alpha=0.7)
    
    plt.xlabel('Value')
    plt.ylabel('Probability')
    
    title = exp_name.replace('_', ' ').title()
    title = title.replace('Rbt', 'RBT').replace('Stlc', 'STLC')

    plt.title(f'{title}')
    
    plt.legend()
    plt.grid(True, alpha=0.3)
    
    plt.savefig(output_path)
    plt.close()

def handle_figure2_plots(config: Config, er : ExperimentResult) -> None:
    for key, training_result in er.training_results.items():
        """Handle distribution plots for figure 2 experiments."""
        initial_path = extract(training_result.log_path, r'Saved metric dist to (.*?loss1_dist_depth_initial\.csv)')
        trained_path = extract(training_result.log_path, r'Saved metric dist to (.*?loss1_dist_depth_trained\.csv)')

        target_is_linear = key.endswith('linear')
        if not target_is_linear:
            assert key.endswith('uniform')

        if config.args.verbose:
            print(f"Initial dist: {initial_path}")
            print(f"Trained dist: {trained_path}")
        
        initial_dist = pd.read_csv(initial_path, sep='\t')
        trained_dist = pd.read_csv(trained_path, sep='\t')
        
        if not initial_dist['val'].equals(trained_dist['val']):
            print("Error: Value columns do not match between initial and trained distributions")
            sys.exit(1)
        
        plot_path = os.path.join(config.output_dir, f"fig2_{key}.png")
        if key.endswith('linear'):
            target_dist = TargetDistribution(name='Linear', val_to_prob=lambda x: x)
        else:
            target_dist = TargetDistribution(name='Uniform', val_to_prob=lambda x: 1.0)

        plot_distributions(initial_dist, trained_dist, plot_path, target_dist, key)
        print(f"Plot saved to: {plot_path}")

def handle_figure3_plots(config: Config, er: ExperimentResult) -> None:
    figure3_log_path = er.training_results[""].log_path
    log_dir = os.path.dirname(figure3_log_path)

    feature_dist_pattern = os.path.join(log_dir, f'feature_dist_feature_spec_entropy_train_feature=true_freq=1-spb={config.args.fig3_samples_per_batch}_prop=wellTyped_feature=typecheck_ft.png')
    unique_curves_pattern = os.path.join(log_dir, f'unique_curves_feature_spec_entropy_train_feature=true_freq=1-spb={config.args.fig3_samples_per_batch}_prop=wellTyped_feature=typecheck_ft.svg')
    
    if config.args.verbose:
        print(f"Looking for plots in directory: {log_dir}")
        print(f"Searching for feature distribution plot: {feature_dist_pattern}")
    
    if not os.path.exists(feature_dist_pattern):
        print("Error: Could not find feature distribution plot")
        print("Contents of log directory:")
        for f in os.listdir(log_dir):
            print(f"  {f}")
        sys.exit(1)
    
    if config.args.verbose:
        print(f"Found feature distribution plot: {feature_dist_pattern}")
    output_path = os.path.join(config.output_dir, 'fig3a_stlc_unique_types_dist.png')
    shutil.copy2(feature_dist_pattern, output_path)
    print(f"Plot saved to: {output_path}")
    
    if config.args.verbose:
        print(f"Searching for unique curves plot: {unique_curves_pattern}")
    
    if not os.path.exists(unique_curves_pattern):
        print("Error: Could not find unique curves plot")
        print("Contents of log directory:")
        for f in os.listdir(log_dir):
            print(f"  {f}")
        sys.exit(1)
    
    if config.args.verbose:
        print(f"Found unique curves plot: {unique_curves_pattern}")
    output_path = os.path.join(config.output_dir, 'fig3b_stlc_cumulative_unique_types.svg')
    shutil.copy2(unique_curves_pattern, output_path)
    print(f"Plot saved to: {output_path}")

def handle_unique_curves(config: Config, er: ExperimentResult, exp_name: str) -> None:
    combined_df = None
    for key, training_result in er.training_results.items():
        csv_path = extract(training_result.log_path, r'Saved unique curves to (.*unique_curves.*\.csv)')
        # the csv has no header, so we add it: 'num_samples', 'untrained', 'trained'
        cum_uniq = pd.read_csv(csv_path, sep='\t', header=None)
        cum_uniq.columns = ['num_samples', 'Untuned', key]

        if combined_df is None:
            combined_df = cum_uniq
        else:
            assert combined_df['num_samples'].equals(cum_uniq['num_samples'])
            combined_df = pd.merge(combined_df, cum_uniq[['num_samples', key]], on='num_samples', how='outer')
    
    plot_path = os.path.join(config.output_dir, f"{exp_name}_cumulative_unique_types.png")

    assert combined_df is not None

    plt.figure(figsize=(10, 6))
    
    # Define color and style mappings
    style_map = {
        'Untuned': {'color': 'red'},
        'Validity': {'color': 'green'},
        'Entropy': {'color': 'orange'},
        'Specification Entropy': {'color': 'blue'},
        # TODO: the below should be blue after we update the paper to do the same
        'Specification Entropy Without Regularization': {'color': 'red', 'linestyle': 'dotted'}
    }
    
    for col in combined_df.columns[1:]:
        if col in style_map:
            plt.plot(combined_df['num_samples'], combined_df[col], label=col, **style_map[col])
        else:
            import warnings
            warnings.warn(f"No style mapping defined for column: {col}")
            plt.plot(combined_df['num_samples'], combined_df[col], label=col)

    plt.legend()
    plt.xlabel("Number of samples")
    plt.ylabel("# of unique valid RBTs")
    plt.savefig(plot_path)
    plt.close()

def handle_figure4_plots(config: Config, er: ExperimentResult) -> None:
    """Handle distribution plots for figure 4 experiments."""
    handle_unique_curves(config, er, "fig4")

def handle_figure10_plots(config: Config, er: ExperimentResult) -> None:
    """Handle distribution plots for figure 10 experiments."""
    handle_unique_curves(config, er, "fig10")

def copy_generators(config: Config, er: ExperimentResult) -> None:
    # create a new directory for the generators if it doesn't exist
    os.makedirs(os.path.join(config.output_dir, "generators"), exist_ok=True)

    for key, training_result in er.training_results.items():
        initial_generator_path = extract(training_result.log_path, r'Saved Coq generator to (.*initial_Generator\.v)')
        trained_generator_path = extract(training_result.log_path, r'Saved Coq generator to (.*trained_Generator\.v)')
        shutil.copy2(initial_generator_path, os.path.join(config.output_dir, f"generators/{key}InitialGenerator.v"))
        shutil.copy2(trained_generator_path, os.path.join(config.output_dir, f"generators/{key}TrainedGenerator.v"))

def handle_figure11_plots(config: Config, er: ExperimentResult) -> None:
    copy_generators(config, er)

def handle_figure12_plots(config: Config, er: ExperimentResult) -> None:
    """Handle distribution plots for figure 11 experiments."""

    training_result = er.training_results["STLCBespoke"]
    log_path = training_result.log_path

    initial_path = extract(training_result.log_path, r'Saved metric dist to (.*?loss1_dist_num_apps_initial\.csv)')
    trained_path = extract(training_result.log_path, r'Saved metric dist to (.*?loss1_dist_num_apps_trained\.csv)')

    if config.args.verbose:
        print(f"Initial dist: {initial_path}")
        print(f"Trained dist: {trained_path}")
    
    initial_dist = pd.read_csv(initial_path, sep='\t')
    trained_dist = pd.read_csv(trained_path, sep='\t')
    
    if not initial_dist['val'].equals(trained_dist['val']):
        print("Error: Value columns do not match between initial and trained distributions")
        sys.exit(1)
    
    plot_path = os.path.join(config.output_dir, f"fig12_dist.png")
    td = TargetDistribution(name='40/30/20/10', val_to_prob=lambda x: {0: 4, 1: 3, 2: 2, 3: 1}.get(x, 0))
    plot_distributions(initial_dist, trained_dist, plot_path, td, "STLC Bespoke Number of Applications")
    print(f"Plot saved to: {plot_path}")


def create_figure2_experiment(args: argparse.Namespace) -> Experiment:
    """Create the list of experiments for figure 2."""
    return Experiment( {
        "rbt_type_based_uniform": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f",
                "LangDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],0,3,true)",
                f"Pair{{MLELossConfig{{RBT}},Float64}}[MLELossConfig{{RBT}}(depth,Uniform())=>{args.fig2_learning_rate}]",
                str(args.fig2_epochs),
                "0.0"
            ],
        ),
        "rbt_type_based_linear": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f",
                "LangDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],0,3,true)",
                f"Pair{{MLELossConfig{{RBT}},Float64}}[MLELossConfig{{RBT}}(depth,Linear())=>{args.fig2_learning_rate}]",
                str(args.fig2_epochs),
                "0.0"
            ],
        ),
        "stlc_type_based_uniform": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f",
                "LangDerivedGenerator{STLC}(Main.Expr.t,Pair{Type,Integer}[Main.Expr.t=>5,Main.Typ.t=>2],0,3,true)",
                f"Pair{{MLELossConfig{{STLC}},Float64}}[MLELossConfig{{STLC}}(depth,Uniform())=>{args.fig2_learning_rate}]",
                str(args.fig2_epochs),
                "0.0"
            ]
        ),
        "stlc_type_based_linear": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f",
                "LangDerivedGenerator{STLC}(Main.Expr.t,Pair{Type,Integer}[Main.Expr.t=>5,Main.Typ.t=>2],0,3,true)",
                f"Pair{{MLELossConfig{{STLC}},Float64}}[MLELossConfig{{STLC}}(depth,Linear())=>{args.fig2_learning_rate}]",
                str(args.fig2_epochs),
                "0.0"
            ]
            ),
            "stlc_bespoke_uniform": TrainingRun(
                command=[
                "julia", "--project", "experiments/tool.jl",
                "-f",
                "LangBespokeSTLCGenerator(5,2)",
                f"Pair{{MLELossConfig{{STLC}},Float64}}[MLELossConfig{{STLC}}(depth,Uniform())=>{args.fig2_learning_rate}]",
                str(args.fig2_epochs),
                "0.0"
            ]
        ),
        "stlc_bespoke_linear": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f",
                "LangBespokeSTLCGenerator(5,2)",
                f"Pair{{MLELossConfig{{STLC}},Float64}}[MLELossConfig{{STLC}}(depth,Linear())=>{args.fig2_learning_rate}]",
                str(args.fig2_epochs),
                "0.0"
            ]
        )
    })

def create_figure3_experiment(args: argparse.Namespace) -> Experiment:
    """Create the experiments for figure 3."""
    return Experiment( {
        "": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
            "-f",
            "LangSiblingDerivedGenerator{STLC}(Main.Expr.t,Pair{Type,Integer}[Main.Expr.t=>5,Main.Typ.t=>2],2,3)",
            f"Pair{{FeatureSpecEntropy{{STLC}},Float64}}[FeatureSpecEntropy{{STLC}}(1,{args.fig3_samples_per_batch},wellTyped,typecheck_ft,true)=>{args.fig3_learning_rate}]",
            str(args.fig3_epochs),
            "0.0"
            ]
        )
    })

# Figure 4: RBT ablation, cumulative unique RBTs
# Entropy (Bounds)
# -f LangSiblingDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],2,3) Pair{SpecEntropy{RBT},Float64}[SpecEntropy{RBT}(2,200,always_true)=>0.03] 2000 0.1

# Specification (Bounds)
# -f LangSiblingDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],2,3) Pair{SatisfyPropertyLoss{RBT},Float64}[SatisfyPropertyLoss{RBT}(isRBTdist)=>0.03] 2000 0.1

# Specification Entropy (Bounds)
# -f LangSiblingDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],2,3) Pair{SpecEntropy{RBT},Float64}[SpecEntropy{RBT}(2,200,isRBT)=>0.3] 2000 0.1

def create_figure4_experiment(args: argparse.Namespace) -> Experiment:
    """Create the list of experiments for figure 4."""
    return Experiment( {
        "Entropy": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f", "-u",
                "LangSiblingDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],2,3)",
                # small version for testing:
                # "LangSiblingDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>2,Main.Color.t=>0],2,3)",
                "Pair{SpecEntropy{RBT},Float64}[SpecEntropy{RBT}(2,200,always_true)=>0.03]",
                str(args.fig4_epochs),
                "0.1"
            ],
        ),
        "Validity": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f", "-u",
                "LangSiblingDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],2,3)",
                "Pair{SatisfyPropertyLoss{RBT},Float64}[SatisfyPropertyLoss{RBT}(isRBTdist)=>0.03]",
                str(args.fig4_epochs),
                "0.1"
            ],
        ),
        "Specification Entropy": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f", "-u",
                "LangSiblingDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],2,3)",
                "Pair{SpecEntropy{RBT},Float64}[SpecEntropy{RBT}(2,200,isRBT)=>0.3]",
                str(args.fig4_epochs),
                "0.1"
            ],
        ),
    })

# Figure 10: RBT ablation on bounds, cumulative unique RBTs

# Specification Entropy (Bounds)
# -f LangSiblingDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],2,3) Pair{SpecEntropy{RBT},Float64}[SpecEntropy{RBT}(2,200,isRBT)=>0.3] 2000 0.1

# Specification Entropy (No bounds)
#-f LangSiblingDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],2,3) Pair{SpecEntropy{RBT},Float64}[SpecEntropy{RBT}(2,200,isRBT)=>0.3] 2000 0.0

def create_figure10_experiment(args: argparse.Namespace) -> Experiment:
    """Create the experiment for figure 10."""
    return Experiment( {
        "Specification Entropy": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f", "-u",
                "LangSiblingDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],2,3)",
                "Pair{SpecEntropy{RBT},Float64}[SpecEntropy{RBT}(2,200,isRBT)=>0.3]",
                str(args.fig10_epochs),
                "0.1"
            ]
        ),
        "Specification Entropy Without Regularization": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f", "-u",
                "LangSiblingDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],2,3)",
                "Pair{SpecEntropy{RBT},Float64}[SpecEntropy{RBT}(2,200,isRBT)=>0.3]",
                str(args.fig10_epochs),
                "0.0"
            ]
        )
    })

def create_figure11_experiment(args: argparse.Namespace) -> Experiment:
    """Create the experiment for figure 11."""
    return Experiment( {
        "BSTTypeBased": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f",
                "LangSiblingDerivedGenerator{BST}(Main.KVTree.t,Pair{Type,Integer}[Main.KVTree.t=>4],2,3)", "Pair{SpecEntropy{BST},Float64}[SpecEntropy{BST}(2,200,isBST)=>0.3]", "2000", "0.1"
            ]
        ),
        "RBTTypeBased": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f",
                "LangSiblingDerivedGenerator{RBT}(Main.ColorKVTree.t,Pair{Type,Integer}[Main.ColorKVTree.t=>4,Main.Color.t=>0],2,3)", "Pair{SpecEntropy{RBT},Float64}[SpecEntropy{RBT}(2,200,isRBT)=>0.3]", "2000", "0.1"
            ]
        ),
        "STLCTypeBased": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f",
                "LangSiblingDerivedGenerator{STLC}(Main.Expr.t,Pair{Type,Integer}[Main.Expr.t=>5,Main.Typ.t=>2],2,3)", "Pair{SpecEntropy{STLC},Float64}[SpecEntropy{STLC}(2,200,wellTyped)=>0.3]", "2000", "0.1"
            ]
        )
    })

def create_figure12_experiment(args: argparse.Namespace) -> Experiment:
    """Create the experiment for figure 12."""
    return Experiment( {
        "STLCBespoke": TrainingRun(
            command=[
                "julia", "--project", "experiments/tool.jl",
                "-f",
                "LangBespokeSTLCGenerator(5,2)", "Pair{MLELossConfig{STLC},Float64}[MLELossConfig{STLC}(num_apps,Target4321())=>1.0]", "250", "0.0"
            ]
        )
    })

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description='Run experiments and generate distribution plots')
    parser.add_argument('--verbose', action='store_true', help='Print detailed file paths')
    parser.add_argument('--force', action='store_true', help='Force re-run experiments even if log files already exist')
    parser.add_argument('--parallel', action='store_true', help='Run experiments in parallel')
    parser.add_argument('--all', action='store_true', help='Run all figures')
    parser.add_argument('--fig2', action='store_true', help='Run figure 2 experiments')
    parser.add_argument('--fig3', action='store_true', help='Run figure 3 experiment')
    parser.add_argument('--fig4', action='store_true', help='Run figure 4 experiments')
    parser.add_argument('--fig10', action='store_true', help='Run figure 10 experiments')
    parser.add_argument('--fast', action='store_true', help='Use faster training settings (fewer epochs, higher learning rates)')
    parser.add_argument('--fig2-learning-rate', type=float, help='Learning rate for figure 2 experiments')
    parser.add_argument('--fig2-epochs', type=int, help='Number of epochs for figure 2 experiments')
    parser.add_argument('--fig3-learning-rate', type=float, help='Learning rate for figure 3 experiment')
    parser.add_argument('--fig3-epochs', type=int, help='Number of epochs for figure 3 experiment')
    parser.add_argument('--fig3-samples-per-batch', type=int, help='Number of samples per batch for figure 3 experiment')
    parser.add_argument('--fig4-epochs', type=int, help='Number of epochs for figure 4 experiments')
    parser.add_argument('--fig10-epochs', type=int, help='Number of epochs for figure 10 experiments')
    parser.add_argument('--fig11', action='store_true', help='Run figure 11 experiments')
    parser.add_argument('--fig12', action='store_true', help='Run figure 12 experiments')
    args, unknown = parser.parse_known_args()
    # assert there are no unknown arguments
    if unknown:
        print(f"Unknown arguments: {unknown}")
        sys.exit(1)
    
    # Validate that at least one figure is selected
    if not (args.all or args.fig2 or args.fig3 or args.fig4 or args.fig10 or args.fig11 or args.fig12):
        print("Error: Must specify at least one figure to run. Use --all, --fig2, --fig3, --fig4, --fig10, --fig11, or --fig12.")
        sys.exit(1)
    
    # Check which figure-specific flags were explicitly specified
    fig2_flags_specified = any(arg.startswith('--fig2') for arg in sys.argv)
    fig3_flags_specified = any(arg.startswith('--fig3') for arg in sys.argv)
    fig4_flags_specified = any(arg.startswith('--fig4') for arg in sys.argv)
    fig10_flags_specified = any(arg.startswith('--fig10') for arg in sys.argv)

    # Validate that figure-specific parameters are only used when their figure is enabled
    if fig2_flags_specified and not (args.all or args.fig2):
        print("Error: Figure 2 parameters specified but figure 2 is not enabled. Use --fig2 or --all.")
        sys.exit(1)
    
    if fig3_flags_specified and not (args.all or args.fig3):
        print("Error: Figure 3 parameters specified but figure 3 is not enabled. Use --fig3 or --all.")
        sys.exit(1)
    
    if fig4_flags_specified and not (args.all or args.fig4):
        print("Error: Figure 4 parameters specified but figure 4 is not enabled. Use --fig4 or --all.")
        sys.exit(1)
    
    if fig10_flags_specified and not (args.all or args.fig10):
        print("Error: Figure 10 parameters specified but figure 10 is not enabled. Use --fig10 or --all.")
        sys.exit(1)
    
    # Set default parameters based on --fast flag
    if args.fast:
        # Fast defaults
        args.fig2_learning_rate = args.fig2_learning_rate if args.fig2_learning_rate is not None else 0.3
        args.fig2_epochs = args.fig2_epochs if args.fig2_epochs is not None else 100
        args.fig3_learning_rate = args.fig3_learning_rate if args.fig3_learning_rate is not None else 1.0
        args.fig3_epochs = args.fig3_epochs if args.fig3_epochs is not None else 200
        args.fig3_samples_per_batch = args.fig3_samples_per_batch if args.fig3_samples_per_batch is not None else 50
        args.fig4_epochs = args.fig4_epochs if args.fig4_epochs is not None else 200
        args.fig10_epochs = args.fig10_epochs if args.fig10_epochs is not None else 200
    else:
        # Normal defaults
        args.fig2_learning_rate = args.fig2_learning_rate if args.fig2_learning_rate is not None else 0.1
        args.fig2_epochs = args.fig2_epochs if args.fig2_epochs is not None else 1000
        args.fig3_learning_rate = args.fig3_learning_rate if args.fig3_learning_rate is not None else 0.3
        args.fig3_epochs = args.fig3_epochs if args.fig3_epochs is not None else 2000
        args.fig3_samples_per_batch = args.fig3_samples_per_batch if args.fig3_samples_per_batch is not None else 200
        args.fig4_epochs = args.fig4_epochs if args.fig4_epochs is not None else 2000
        args.fig10_epochs = args.fig10_epochs if args.fig10_epochs is not None else 2000
    
    return args

def main():
    args = parse_args()
    output_dir_name = "experiments-output-fast" if args.fast else "experiments-output"
    output_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), output_dir_name)
    os.makedirs(output_dir, exist_ok=True)
    config = Config(output_dir=output_dir, args=args)
    
    # Create experiments
    experiments = []
    experiments.append(create_figure2_experiment(args) if args.fig2 else empty_experiment)
    experiments.append(create_figure3_experiment(args) if args.fig3 else empty_experiment)
    experiments.append(create_figure4_experiment(args) if args.fig4 else empty_experiment)
    experiments.append(create_figure10_experiment(args) if args.fig10 else empty_experiment)
    experiments.append(create_figure11_experiment(args) if args.fig11 else empty_experiment)
    experiments.append(create_figure12_experiment(args) if args.fig12 else empty_experiment)
    
    if args.parallel:
        result = run_experiments_parallel(config, experiments)
    else:
        result = run_experiments_sequential(config, experiments)

    fig2_result, fig3_result, fig4_result, fig10_result, fig11_result, fig12_result = result

    if args.fig2 or args.all:
        handle_figure2_plots(config, fig2_result)

    if args.fig3 or args.all:
        handle_figure3_plots(config, fig3_result)

    if args.fig4 or args.all:
        handle_figure4_plots(config, fig4_result)

    if args.fig10 or args.all:
        handle_figure10_plots(config, fig10_result)

    if args.fig11 or args.all:
        handle_figure11_plots(config, fig11_result)

    if args.fig12 or args.all:
        handle_figure12_plots(config, fig12_result)
            
if __name__ == "__main__":
    main()

