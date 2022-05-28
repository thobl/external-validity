#!/usr/bin/env bash

docker image build -t ext_val docker
docker save -o docker/ext_val.tar ext_val

cd docker/
mkdir -p ext_val/data/input_data/raw/
mkdir ext_val/data/output_data/
mkdir ext_val/data/plots/

cp ext_val.tar ext_val/
cp enter.sh ext_val/
cp kill.sh ext_val/
cp load.sh ext_val/
cp run.sh ext_val/
cp setup_data.sh ext_val/

rm ext_val.zip
zip -r ext_val.zip ext_val/
rm -rf ext_val/
