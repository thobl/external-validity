# Scripts #

## merge-csv.sh ##

Calling, e.g. `./scripts/merge-csv.sh output_data/size` merges all
files csv files in `output_data/size/` into a single csv file.  It is
assumed that all files in `output_data/size/` have the same columns.
The script adds the column `graph`.  Its value for each row is derived
from the name of csv file it comes from, e.g., the rows from
`output_data/size/dolphins.csv` will have the value `dolphins` in the
column `graph`.

## networks ##

A collection of scripts for selecting and downloading networks from
network repository.  See [networks/README.md](networks/README.md) for
more details
