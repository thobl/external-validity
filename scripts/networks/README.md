# Network Scripts #

A collection of scripts for selecting and downloading networks from
network repository.  The scripts should be run from the root of the
repository, e.g., as `./scripts/networks/10_networks_html_to_csv.sh`,
(they contain some hard-coded paths).

## 10_networks_html_to_csv.sh ##

Parses `scripts/networks/data/all_networks_html.txt`, containing the
[table of all networks from network
repository](https://networkrepository.com/networks.php) in html format
and outputs it as csv into `scripts/networks/data/all_networks.csv`.

## 20_select_networks.R ##

Selects all networks from `scripts/networks/data/all_networks.csv`
that have less than 1M edges and more than 30 vertices.  The resulting
list of networks is written to
`scripts/networks/data/selected_networks.txt`.

## 30_nr_download_networks.sh ##

Download networks from network repository.  The networks that should
be downloaded are hardcoded into the script (copied from
`scripts/networks/data/selected_networks.txt`).  The networks are
downloaded to `input_data/raw/`.  The script takes care of unpacking
the downloaded zip file, removing unwanted files and converting the
files to edge lists.  The weights of weighted graphs are removed.

## 40_find_duplicate_networks.R ##

This script uses some graph stats to be computed before.
Specifically, `output_data/clustering_coeff.csv` and
`output_data/deg_distr.csv` have to exist.  The script first duplicate
candidates based on equal degree and clustering stats.  The candidates
are then checked for actually being isomorphic.  From each group of
isomorphic graphs, all but one are written to
`scripts/networks/data/duplicates.txt`.

The duplicate groups are saved in
`scripts/networks/data/duplicate_network_groups.RDS` to avoid the
somewhat expensive recomputation.

**Required libraries:** `igraph`

## 50_remove_duplicates.sh ##

Removes all graphs from `input_data/raw/` that are listed in
`scripts/networks/data/duplicates.txt`.
