#!/usr/bin/env bash

NAME=${1%/}

# print the head once
file=($NAME/*.csv)
head -n1 $file | sed 's/^/graph,/' > $NAME.csv

# print the content
for file in $NAME/*.csv; do
    graph=$(basename $file)
    graph=${graph%.*}
    tail -n+2 $file | sed "s/^/$graph,/" >> $NAME.csv
done;
