#!/usr/bin/env bash

./experiments.py gen prep stats bonus algo merge_csv

echo "building the plots"
Rscript R/create_plots.R > R/output/console_output.txt
