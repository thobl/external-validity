#!/usr/bin/env bash

rm -rf data/
mkdir data/
cd data
wget https://zenodo.org/record/8046834/files/input_data.zip
unzip input_data.zip
rm input_data.zip
mkdir output_data
mkdir plots
