# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "click",
#     "psutil",
#     "numpy",
# ]
# ///

# out put format: fuzzer, target, program, patch, log, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, median, mean, std


import click
from pathlib import Path
import json
import numpy as np
import csv
import sys



# the res is a dict which key is index of the result
def gen_res_of_one_setting(data: dict) -> dict:
    for fuzzer in data.keys():
        for target in data[fuzzer].keys():
            for program in data[fuzzer][target].keys():
                for patch in data[fuzzer][target][program].keys():
                    yield fuzzer, target, program, patch, data[fuzzer][target][program][patch]

def calculate_stats(values):
    if not values:
        return 0
    values = np.array(values)
    return np.median(values)

def process_metrics(res: dict) -> dict:
    metrics = {}
    # Initialize arrays for reached and triggered counts
    for metric in res['0']['reached'].keys():
        metric_name = "BUG" if metric == "%MAGMA_BUG%" else metric
        metrics[f"{metric_name}_R"] = []
        metrics[f"{metric_name}_T"] = []
    
    # Collect data for each run (0-9)
    for run in range(10):
        run_data = res.get(str(run), {})
        reached_metrics = run_data.get('reached', {})
        triggered_metrics = run_data.get('triggered', {})
        
        for metric in reached_metrics:
            metric_name = "BUG" if metric == "%MAGMA_BUG%" else metric
            metrics[f"{metric_name}_R"].append(reached_metrics[metric])
            # If metric exists in reached but not in triggered, it's a timeout
            if metric in triggered_metrics:
                metrics[f"{metric_name}_T"].append(triggered_metrics[metric])
            else:
                metrics[f"{metric_name}_T"].append(99999)  # timeout value
    
    return metrics

@click.command()
@click.argument("json_file", type=click.Path(exists=True, path_type=Path))
def cli(json_file: Path) -> None:
    data = json.load(json_file.open()).get("results")
    if not data:
        print("No results found in JSON file", file=sys.stderr)
        return

    # Setup CSV writer
    writer = csv.writer(sys.stdout)
    header = ['fuzzer', 'target', 'program', 'patch', 'log']
    header.extend([str(i) for i in range(10)])
    header.append('median')
    writer.writerow(header)

    for fuzzer, target, program, patch, res in gen_res_of_one_setting(data):
        metrics = process_metrics(res)
        
        for metric_name, values in metrics.items():
            row = [fuzzer, target, program, patch, metric_name]
            # Add individual run values
            row.extend(values)
            # Calculate and add median
            median = calculate_stats(values)
            row.append(median)
            writer.writerow(row)

if __name__ == "__main__":
    cli()
