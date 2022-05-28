#!/usr/bin/env bash

######################################################################
# function for creating zip file
create_zip() {
    cd data_packages/
    rm -f "$1.zip"
    zip -r "$1.zip" "$1/"
    cd -
}


######################################################################
# edge list: generated
cp_edge_list_pack() {
    mkdir -p "data_packages/edge_lists_$2/"

    find input_data/edge_list/ -name $1 \
         -exec cp {} "data_packages/edge_lists_$2/" \;

    create_zip "edge_lists_$2"
}

cp_edge_list_pack "er_n*m=250*" er
cp_edge_list_pack "er_n*m=500*" er_deg_20

cp_edge_list_pack "cl_n*deg=10*" cl
cp_edge_list_pack "cl_n*deg=20*" cl_deg_20

cp_edge_list_pack "girg_n*deg=10*[0-9]" girg
cp_edge_list_pack "girg_n*deg=20*[0-9]" girg_deg_20
cp_edge_list_pack "girg_n*_square" girg_square
cp_edge_list_pack "girg_deg_scaling_n*" girg_deg_scaling


######################################################################
# edge list: real
mkdir -p data_packages/edge_lists_real/
find input_data/edge_list/ -type f \
     -not -name "er_n*m=250*" \
     -not -name "er_n*m=500*" \
     -not -name "cl_n*deg=10*" \
     -not -name "cl_n*deg=20*" \
     -not -name "girg_n*deg=10*[0-9]" \
     -not -name "girg_n*deg=20*[0-9]" \
     -not -name "girg_n*_square" \
     -not -name "girg_deg_scaling_n*" \
     -exec cp {} "data_packages/edge_lists_real/" \;

create_zip "edge_lists_real"

######################################################################
# raw-data
mkdir -p data_packages/input_data/raw/
find input_data/raw/ -type f \
     -not -name "er_n*m=250*" \
     -not -name "er_n*m=500*" \
     -not -name "cl_n*deg=10*" \
     -not -name "cl_n*deg=20*" \
     -not -name "girg_n*deg=10*[0-9]" \
     -not -name "girg_n*deg=20*[0-9]" \
     -not -name "girg_n*_square" \
     -not -name "girg_deg_scaling_n*" \
     -exec cp {} "data_packages/input_data/raw/" \;

create_zip "input_data"

######################################################################
# output data
mkdir -p data_packages/output_data/
cp output_data/*.csv data_packages/output_data/
create_zip "output_data"

######################################################################
# data export (combined csv)
cp R/output/data_export.csv data_packages/graph_stats.csv
cp R/output/data_export_real.csv data_packages/graph_stats_real.csv
cp R/output/data_export_gen.csv data_packages/graph_stats_gen.csv
