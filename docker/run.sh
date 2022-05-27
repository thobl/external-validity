#!/usr/bin/env bash

docker run --name ext_val --rm\
       --user "$(id -u):$(id -g)"\
       -v $PWD/data/input_data:/ext_val/input_data\
       -v $PWD/data/output_data:/ext_val/output_data\
       -v $PWD/data/plots:/ext_val/R/output\
       ext_val &
