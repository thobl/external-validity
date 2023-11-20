# External Validity of Average-Case Analyses #

This repository contains the code to reproduce our experiments from
the paper

> Thomas Bläsius, Philipp Fischbeck: *On the External Validity of
> Average-Case Analyses of Graph Algorithms.*
> [arxiv.org/abs/2205.15066](https://arxiv.org/abs/2205.15066)

To reproduce our experiments, you can either use the docker container
or run it natively.  We first describe these two approaches.  If you
only want to run a subset of experiments, apply some modifications, or
add your own experiments, read the subsequent details on our
experiment setup.

Additional data can be found on
[zenodo.org/record/8058432](https://zenodo.org/record/8058432).

An interactive visualization of all data, with ways to flexibly filter
and download them, can be found at [external-validity.iti.kit.edu](https://external-validity.iti.kit.edu/).

## Running it in the Docker Container ##

For running the docker container, you of course need docker.

### In a Nutshell ###

On the host computer (the one you are running the experiments on), do
the following to get the container running.

```terminal
wget https://zenodo.org/record/8058432/files/ext-val.zip
unzip ext_val.zip
cd ext_val
./load.sh
./setup_data.sh
./run.sh
./enter.sh
```

The last command enters a bash in the docker container.  You might want
to run it as `screen ./enter.sh` if you are running on some server and
want to be able to log out and back in again while running the
experiments.

In the container, start the experiments as follows.  This uses all but
two cores of the machine and may take a while (but you'll see progress
bars).

```termian
./run_and_build_plots.sh
```

Afterwards, exit and kill the container.

```termian
exit
./kill.sh
```

The computed data should now be in `data/`.

### Some More Details ###

The file `ext_val.zip` contains the docker container `ext_val.tar` as
well as the scripts used above.  Essentially the above process does
the following.

  * `load.sh` tells docker that the image ext_val exists
  * `setup_data.sh` downloads the network data for running the
    experiments.  Alternatively, you can manually download the
    networks from
    [zenodo.org/record/8058432/files/input_data.zip](https://zenodo.org/record/8058432/files/input_data.zip)
    and unzip them.  Check that the networks are located under
    `data/input_data/raw/`.
  * `run.sh` starts the docker container.  It mounts the host
    directories `data/input_data`, `data/output_data`, and
    `data/plots` to the container folders `/ext_val/input_data`,
    `/ext_val/output_data`, and `/ext_val/R/output`, respectively.
    You can use different host folders but should mount something to
    each of these three container folders.  Moreover, the folder
    mounted to `/ext_val/input_data` should contain the networks as
    described above.
  * `enter.sh` executes `bash` in the docker container
  * `./run_and_build_plots.sh` in the container runs the experiments.
    Also see details on the experiment setup below.
  * `kill.sh` kills the container (otherwise it keeps running)


## Running it Natively ##

In the following description, we assume a Linux-like environment.

### Dependencies ###

The c++ code can be build using cmake.  To run the experiments you
need python3 with pip.  Further dependencies are included via
submodules.  Run the following commands to set up these dependencies.

```terminal
git submodule init
git submodule update
cd run
pip3 install .
```

If you also want to use the R-scripts to create the plots, you need R.
To install the required R-packages, run the following command.

```terminal
R -e 'install.packages(c("ggplot2", "egg", "xtable", "extrafont", "plyr", "dplyr", "reshape2", "grid", "ggpubr", "GGally", "showtext", "plotly", "igraph"), repos="https://cloud.r-project.org/")'
```

Additionally, to create the pdf plots, the file
`lmroman10-regular.otf` must be available in your system.  You can,
e.g., just download it as follows.

```terminal
wget http://www.gust.org.pl/projects/e-foundry/latin-modern/download/lm2.004otf.zip &&\
    unzip -p lm2.004otf.zip lmroman10-regular.otf > lmroman10-regular.otf &&\
    rm lm2.004otf.zip
```

### Building ###

To build the c++ code, you can simply run the `build.sh` script.
Alternatively, do the following.

```terminal
mkdir code/release/
cd code/release/
cmake ..
make
```

It is important to build in `code/release/` so that the experiment
script can find the executables.


### Getting the Input Data ###

The input data is not contained in this repository.  To get the data
and put it in the right place do the following.

```terminal
wget https://zenodo.org/record/8058432/files/input_data.zip
unzip input_data.zip
rm input_data.zip
```

### Running the Experiments ###

Running the experiments is done via `experiments.py`.  Do the
following to run all experiments (using all but 2 cores of the
machine).  This may take some time.

```terminal
./experiments.py gen prep stats bonus algo merge_csv
```

### Plottings ###

To create all plots, run `Rscript R/create_plots.R`.  The script
`run_and_build_plots.sh` runs all experiments and afterwards builds
the plots.


## Experiment Setup ##

We use the python module [run](https://github.com/thobl/run) for our
experiments.  Running `./experiments.py` will show an overview of the
available experiments without running them.  Selecting what to run is
done by calling it with the names of the experiments or groups as
additional parameters, e.g., `./experiment.py cliques coloring` will
run the experiments `cliques` and `coloring` and `./experiments.py
algo` will run everything in the `algo` group.  The following groups
and experiments are available.

  * `gen` generate random networks
      * `gen_girg` generate geometric inhomogeneous random graphs
        (GIRG)
      * `gen_girg_deg_scaling` generate GIRGs for degree scaling
        experiments
      * `gen_cl` generate Chung-Lu graphs
      * `gen_el` generate Erdős-Rényi graphs
  * `rm_generated` remove generated graphs as well as additional data
    generated for these graphs (this is useful during development,
    when regularly changing the parameters of the generated networks);
    `rm_girg`, `rm_girg_deg_scaling`, `rm_cl`, `rm_el` should be
    self-explanatory
  * `prep` things that should be done before running the other
    experiments
      * `prepare_graph_formats` pre-processes the graphs in
        `input_data/raw/` by reducing them to the largest connected
        component and preparing different graph formats (these are
        saved in different subfolders of `input_data/`)
  * `stats` compute general graph statistics for all graphs
      * `deg_distribution` histogram of the degree distribution
      * `avg_deg_locality` average degree locality
      * `avg_detour_dist` average detour distance
      * `avg_dist` approximate average distance
      * `size` number of vertices and edges
      * `clustering_coeff` average local clustering coefficient
      * `closure` closure
      * `weak_closure` weak closure
      * `degeneracey` degeneracy
  * `bonus` additional experiments
      * `avg_dist_tests` evaluation of the average distance
        approximation
  * `algo` run the different algorithms
      * `dist` different variants of the BFS (uni- and bidirectional)
        on 100 random st-pairs
      * `diameter_bonds` doublesweep and foursweep bounds for the
        diameter
      * `diameter_exact` iFUB algorithm with different central
        vertices (iFUB+hd and iFUB+4-sweephd)
      * `cliques` enumerate all maximal cliques
      * `coloring` kernelization algorithm for computing the chromatic
        number
      * `vertex_cover_dominance` kernelization algorithm for computing
        a minimum vertex cover
      * `louvain` first phase of the louvain algorithm
  * `post` some post processing of the results
      * `merge_csv` Most previous experiments create one csv-file per
        graph in the corresponding subfolder of `output_data`.  This
        has the advantage that one can easily add graphs without
        recomputing for all graphs.  `merge_csv` merges these into one
        csv file per experiment.
      * `merge_csv_force` merge csv files even if the merged file
        already exists

### Files & Directories ###

Besides `experiments.py`, there are the following noteworthy files and
directories (some of which are only created by running the
experiments).

  * `R/` R code for analyzing the data in `output_data`
      * `R/create_plots.R` single R script creating all plots, tables
        and data export
      * `R/output/` output folder for the plots
      * `R/output/data_export.csv` a single table aggregating all the
        data
  * `code/` the c++ code
  * `input_data/` graph data in different formats
      * `input_data/raw/` original graph as edge list (one edge per
        line); no guarantees on where node indices start (usually at 0
        or 1) or whether they are consecutive
      * `input_data/edge_list/` edge list; node indices are
        consecutive starting at 0; every edge is contained only for
        one direction
      * `input_data/adj_array/`: format for easy loading as adjacency
        array; first line contains the number of nodes and edges;
        every following line represents an edge as `<edge_id>
        <node1_id> <node2_id>`; each edge is contained twice, once for
        each direction
      * `input_data/metis/` metis format
  * `output_data/` stats computed in our experiments
  * `build.sh` build the c++ code
  * `package_data.sh` script for packaging the data for publication
  * `run_and_build_plots.sh` run all experiments and create the plots
  * `scripts/` some additional helper scripts
  * `docker/` scripts for building the docker image
  * `girgs/` submodule for generating GIRGs
  * `run/` submodule for python module running the experiments
  * `quick-cliques/` submodule for enumerating maximal cliques

## Changelog ##

### 20.06.2023 Bugfix ###

There was an error in the detection of network duplicates, which meant
not all network duplicates were properly detected. We updated the 
detection script and the considered networks.

### 23.10.2022 Bugfix ###

There was an error in the calculation of the variance of the degree
distribution.  Fixing this error made the following additional changes
necessary.

  * We adjusted the power-law exponents used for the generated
    networks to again yield graphs with evenly spaced heterogeneity
    values.
  * There are few real-world networks with very high or very low
    heterogeneity values.  To improve readability, we removed those
    networks from the main plots and created additional plots that
    include them.
