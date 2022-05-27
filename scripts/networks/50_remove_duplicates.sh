#!/usr/bin/env bash

cd input_data/raw
xargs rm < ../../scripts/networks/data/duplicates.txt 
