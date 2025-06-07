import argparse
import json
import os
import sys
import multiprocessing as mp
from concurrent.futures import ProcessPoolExecutor
import logging
from pathlib import Path
from itertools import groupby
from typing import List, Tuple, Any

# Get the directory of the current script.
script_dir = os.path.dirname(os.path.realpath(__file__))
# Construct the path to the 'tool' directory, which is three levels up from the script's directory.
tool_path = os.path.abspath(os.path.join(script_dir, '..', '..', '..', 'tool'))
# Prepend the 'tool' directory to sys.path to ensure our local 'benchtool' is imported.
sys.path.insert(0, tool_path)

from benchtool.Coq import Coq
from benchtool.Types import TrialConfig, ReplaceLevel

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(processName)s - %(levelname)s - %(message)s'
)

def process_variant_tasks(variant_task_group):
    """Process all tasks for a specific variant."""
    workload, variant, tasks, results_path = variant_task_group
    
    try:
        tool = Coq(results=results_path, replace_level=ReplaceLevel.SKIP)
        
        # Apply variant once for all tasks in this group
        run_trial = tool.apply_variant(workload, variant, no_base=True)
        
        results = []
        for strategy, property in tasks:
            try:
                cfg = TrialConfig(
                    workload=workload,
                    strategy=strategy.name,
                    property=property,
                    trials=11,
                    timeout=60,
                    short_circuit=False
                )
                
                run_trial(cfg)
                logging.info(f"Completed task: {workload.name},{strategy.name},{variant.name},{property}")
                results.append(True)
            except Exception as e:
                logging.error(f"Error processing task {workload.name},{strategy.name},{variant.name},{property}: {str(e)}")
                results.append(False)
        
        return results
    except Exception as e:
        logging.error(f"Error setting up variant {workload.name},{variant.name}: {str(e)}")
        return [False] * len(tasks)

def collect(results: str):
    tool = Coq(results=results, replace_level=ReplaceLevel.SKIP)
    variant_tasks = []  # List of (workload, variant, [(strategy, property)], results_path)
    
    # Create results directory if it doesn't exist
    Path(results).mkdir(parents=True, exist_ok=True)
    
    # First gather all tasks grouped by variant
    for workload in tool.all_workloads():
        logging.info(f"Preprocessing {workload.name}")
        tool._preprocess(workload)
        
        tasks_json_path = f'experiments/coq-experiments/5.1/{workload.name}_tasks.json'
        if not os.path.exists(tasks_json_path):
            logging.warning(f"Tasks file not found: {tasks_json_path}")
            continue
            
        tasks_json = json.load(open(tasks_json_path))
        
        for variant in tool.all_variants(workload):
            if variant.name == 'base':
                continue
                
            # Collect all tasks for this variant
            variant_task_list = []
            for strategy in tool.all_strategies(workload):
                for property in tool.all_properties(workload):
                    property = 'test_' + property
                    
                    # Skip if task not in tasks_json
                    if tasks_json['tasks'] and property not in tasks_json['tasks'][variant.name]:
                        continue
                    
                    # Check if task is already completed
                    file = f'{workload.name},{strategy.name},{variant.name},{property}'
                    if f'{file}.json' in os.listdir(results):
                        continue
                    
                    variant_task_list.append((strategy, property))
            
            # Only add to processing queue if there are tasks for this variant
            if variant_task_list:
                variant_tasks.append((workload, variant, variant_task_list, results))
    
    # Process variant groups in parallel using a process pool
    num_processes = max(1, mp.cpu_count() - 1)  # Leave one CPU free
    logging.info(f"Starting processing with {num_processes} processes")
    
    total_tasks = sum(len(tasks) for _, _, tasks, _ in variant_tasks)
    logging.info(f"Total tasks to process: {total_tasks}")
    
    with ProcessPoolExecutor(max_workers=num_processes) as executor:
        all_results = []
        for results in executor.map(process_variant_tasks, variant_tasks):
            all_results.extend(results)
    
    # Report completion statistics
    completed_tasks = sum(1 for r in all_results if r)
    failed_tasks = total_tasks - completed_tasks
    
    logging.info(f"Processing complete. Total tasks: {total_tasks}")
    logging.info(f"Successfully completed: {completed_tasks}")
    logging.info(f"Failed tasks: {failed_tasks}")

if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--data', help='path to folder for JSON data')
    args = p.parse_args()
    
    logging.info(f"CWD: {os.getcwd()}")
    results_path = f'{os.getcwd()}/{args.data}'
    collect(results_path)
