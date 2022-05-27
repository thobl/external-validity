#!/usr/bin/env python3
import os
import glob
import run
import multiprocessing

run.use_cores(multiprocessing.cpu_count() - 2)

######################################################################
######################################################################
######################################################################
run.section("[1/3] Creating or removing randomly generated graphs")

######################################################################
# generate random graphs
run.group("gen")


# generate girgs
def gen_girgs(name, n, deg, dim, ple, T, square, seed):
    """Adding experiments that generate GIRGs."""
    command = "code/release/girg -n [[n]] --deg [[deg]] --dim [[dim]] --ple [[ple]] -T [[T]] [[square_cmd]] --seed [[seed]] [[file]]"
    graphname = (
        name
        + "_n=[[n]]_deg=[[deg]]_dim=[[dim]]_ple=[[ple]]_T=[[T]]_seed=[[seed]][[square_name]]"
    )
    run.add(
        "gen_" + name,
        command,
        {
            "n": n,
            "deg": deg,
            "dim": dim,
            "ple": ple,
            "T": T,
            "square_cmd": lambda args: "--square" if args["square"] else "",
            "square_name": lambda args: "_square" if args["square"] else "",
            "square": square,
            "seed": seed,
            "name": graphname,
            "file": "input_data/raw/[[name]]",
        },
        stdout_file="output_data/girg_attributes/[[name]].csv",
    )


gen_girgs(
    name="girg",
    n=50000,
    deg=10,
    dim=2,
    ple=[2.1, 2.36, 2.65, 3.0, 3.4, 4.0, 4.9, 6.2, 8.6, 25.0],
    T=[0.0, 0.4, 0.53, 0.62, 0.7, 0.76, 0.82, 0.88, 0.94, 0.9999],
    square=[False, True],
    seed=[64, 321, 356, 489, 836],
)

gen_girgs(
    name="girg",
    n=50000,
    deg=20,
    dim=2,
    ple=[2.1, 2.36, 2.65, 3.0, 3.4, 4.0, 4.9, 6.2, 8.6, 25.0],
    T=[0.0, 0.4, 0.53, 0.62, 0.7, 0.76, 0.82, 0.88, 0.94, 0.9999],
    square=False,
    seed=[64, 321, 356, 489, 836],
)

gen_girgs(
    name="girg_deg_scaling",
    n=50000,
    deg=[2 * x for x in range(3, 13)],
    dim=2,
    ple=6.2,
    T=[0.62, 0.76, 0.88],
    square=False,
    seed=list(range(1000, 1030)),
)

# generate Chung-Lu
run.add(
    "gen_cl",
    "code/release/chung_lu -n [[n]] --deg [[deg]] --ple [[ple]] [[file]]",
    {
        "n": 50000,
        "deg": [10, 20],
        "ple": [2.1, 2.36, 2.65, 3.0, 3.4, 4.0, 4.9, 6.2, 8.6, 25.0],
        "seed": [64, 321, 356, 489, 836],
        "name": "cl_n=[[n]]_deg=[[deg]]_ple=[[ple]]_seed=[[seed]]",
        "file": "input_data/raw/[[name]]",
    },
    stdout_file="output_data/cl_attributes/[[name]].csv",
)

# generate Erdős-Rényi graphs
run.add(
    "gen_er",
    "code/release/random_graph -n [[n]] -m [[m]] --seed [[seed]] [[file]]",
    {
        "n": 50000,
        "m": [250000, 500000],
        "seed": [64, 321, 356, 489, 836],
        "name": "er_n=[[n]]_m=[[m]]_seed=[[seed]]",
        "file": "input_data/raw/[[name]]",
    },
    stdout_file="output_data/er_attributes/[[name]].csv",
)

######################################################################
# remove previously generated graphs and stats computed for them
run.group("rm_generated")

# names of all output stats
output_names = [
    os.path.basename(os.path.dirname(dir)) for dir in glob.glob("output_data/*/")
]

# remove all graphs/results with certain prefix
prefixes = ["girg", "girg_deg_scaling", "er", "cl"]
run.add(
    "rm_[[prefix]]",
    "rm -f input_data/[[format]]/[[prefix]]_n*",
    {
        "format": [
            "raw",
            "adj_array",
            "edge_list",
            # "pace_format",
            "metis",
            # "quick_cliques_format",
        ],
        "prefix": prefixes,
    },
)
run.add(
    "rm_[[prefix]]",
    "rm -f output_data/[[output]]/[[prefix]]_n*",
    {"output": output_names, "prefix": prefixes},
)

run.run()

######################################################################
######################################################################
######################################################################
run.section("[2/3] Running the actual computations")

# names of all graphs
input_names_all = [os.path.basename(f) for f in glob.glob("input_data/raw/*")]

# special graphs: for degree scaling
input_names_girg_deg_scaling = [
    name for name in input_names_all if name.startswith("girg_deg_scaling_")
]

# special graphs: high degree
input_names_gen_high_deg = [
    name
    for name in input_names_all
    if ("deg=20" in name or "m=500000" in name)
    and not name.startswith("girg_deg_scaling_")
]

# main data set
input_names = [
    name
    for name in input_names_all
    if not name.startswith("girg_deg_scaling_")
    and "deg=20" not in name
    and "m=500000" not in name
]


######################################################################
# preparations
run.group("prep")

# reduce largest connected component and convert to different formats
run.add(
    "prepare_graph_formats",
    "code/release/prepare_graph_formats input_data/raw/[[input]]",
    {"input": input_names_all},
    creates_file="input_data/edge_list/[[input]]",
)


######################################################################
# simple experiments
def simple_experiment(name, input_names):
    """Adding a simple experiment just running one command on the given inputs."""
    run.add(
        "[[name]]",
        "code/release/[[name]] input_data/adj_array/[[input]]",
        {
            "input": input_names,
            "name": name,
        },
        stdout_file="output_data/[[name]]/[[input]].csv",
    )


######################################################################
# compute graph stats
run.group("stats")

# stats we need for all data sets
simple_experiment(
    ["deg_distr", "avg_deg_locality", "avg_detour_dist", "avg_dist", "size"],
    input_names_all,
)

# stats for only the main data set
simple_experiment(
    ["clustering_coeff", "closure", "closure_weak", "degeneracy"],
    input_names,
)


######################################################################
# average dist tests
run.group("bonus")

avg_dist_tests_command = (
    "code/release/avg_dist --algo [[algo]] --sample_size [[sample_size]] "
    "--no-header input_data/adj_array/[[input]]"
)

avg_dist_tests_input = [
    "socfb-Columbia2",
    "ca-HepPh",
    "escorts",
    "air03",
    "sinc15",
    "fd15",
    "crack",
    "inlet",
]

run.add(
    "avg_dist_tests",
    avg_dist_tests_command,
    {
        "input": avg_dist_tests_input,
        "algo": ["weighted", "weighted_no_correct"],
        "sample_size": [50, 100, 200, 400, 800],
        "iteration": list(range(50)),
    },
    stdout_file="output_data/avg_dist_tests/[[input]].csv",
    header_command="code/release/avg_dist --only-header",
)

run.add(
    "avg_dist_tests",
    avg_dist_tests_command,
    {
        "input": avg_dist_tests_input,
        "algo": "uniform",
        "sample_size": [50, 100, 200, 400, 800, 1600, 3200, 6400],
        "iteration": list(range(50)),
    },
    stdout_file="output_data/avg_dist_tests/[[input]].csv",
    header_command="code/release/avg_dist --only-header",
)

run.add(
    "avg_dist_tests",
    "code/release/avg_dist --algo exact --no-header input_data/adj_array/[[input]]",
    {"input": avg_dist_tests_input},
    stdout_file="output_data/avg_dist_tests/[[input]].csv",
    header_command="code/release/avg_dist --only-header",
)

######################################################################
# running algorithms
run.group("algo")

# computing shortest paths
dist_command = (
    "code/release/dist --algo [[algo]] --pairs [[pairs]] --seed [[seed]] "
    "--no-header input_data/adj_array/[[input]]"
)

run.add(
    "dist",
    dist_command,
    {
        "algo": ["bfs", "bfs_bi_balanced", "bfs_bi_always_swap"],
        "pairs": 100,
        "seed": 3404785993,
        "input": input_names,
    },
    stdout_file="output_data/dist/[[input]].csv",
    header_command="code/release/dist --only-header",
)

# diameter bounds
run.add(
    "diameter_bounds",
    "code/release/diameter_bounds --algo [[algo]] --no-header input_data/adj_array/[[input]]",
    {"algo": ["double_sweep", "four_sweep"], "input": input_names},
    stdout_file="output_data/diameter_bounds/[[input]].csv",
    header_command="code/release/diameter_bounds --only-header",
)

# diameter exact
run.add(
    "diameter_exact",
    "timeout [[timeout]] code/release/diameter_exact --algo [[algo]] --no-header input_data/adj_array/[[input]]",
    {"algo": ["ifub_foursweephd", "ifub_hd"], "input": input_names, "timeout": 1800},
    allowed_return_codes=[0, 124, -15],
    stdout_file="output_data/diameter_exact/[[input]].csv",
    stdout_mod=lambda out, res: (
        out if res.returncode == 0 else "[[algo]],0,0,[[timeout]]"
    ),
    header_command="code/release/diameter_exact --only-header",
)

# enumerating cliques
run.add(
    "cliques",
    "timeout [[timeout]] code/release/cliques --no-header input_data/metis/[[input]].graph",
    {"input": input_names, "timeout": 1800},
    allowed_return_codes=[0, 124, -15],
    stdout_file="output_data/cliques/[[input]].csv",
    stdout_mod=lambda out, res: (out if res.returncode == 0 else "0,0,[[timeout]]"),
    header_command="code/release/cliques --only-header",
)

# finding chromatic number (for all networks, including degree scaling)
run.add(
    "coloring",
    "timeout [[timeout]] code/release/coloring --no-header input_data/adj_array/[[input]]",
    {"input": input_names_all, "timeout": 1800},
    allowed_return_codes=[0, 124, -15],
    stdout_file="output_data/coloring/[[input]].csv",
    stdout_mod=lambda out, res: (
        out if res.returncode == 0 else "-1,-1,[[timeout]],[[timeout]]"
    ),
    header_command="code/release/coloring --only-header",
)

# simple algorithms
simple_experiment(["vertex_cover_dominance", "louvain"], input_names)

run.run()


######################################################################
######################################################################
######################################################################
run.section("[3/3] Postprocessing of the results")

# names of all output stats (might have changed by previous runs)
output_names = [
    os.path.basename(os.path.dirname(dir)) for dir in glob.glob("output_data/*/")
]

######################################################################
# some postprocessing
run.group("post")

# merge csv
run.add(
    "merge_csv",
    "scripts/merge-csv.sh output_data/[[output]]",
    {"output": output_names},
    creates_file="output_data/[[output]].csv",
)

# merge csv (always run and overwrite)
run.add(
    "merge_csv_force",
    "scripts/merge-csv.sh output_data/[[output]]",
    {"output": output_names},
)

run.run()
