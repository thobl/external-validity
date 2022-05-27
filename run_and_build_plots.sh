#!/usr/bin/env bash

./experiments.py gen prep stats bonus algo merge_csv

Rscript R/create_plots.R
