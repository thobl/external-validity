#!/usr/bin/env bash

OUTPUT=scripts/networks/data/all_networks.csv

echo "name,type,n,n_formated,m,m_formated,deg_max,deg_max_formated,deg_avg,deg_avg_formated,assort_coeff,assort_coeff_formated,triangle_count,triangle_count_formated,triangle_edge_avg,triangle_edge_avg_formated,triangle_edge_max,triangle_edge_max_formated,clustering_avg_local,clustering_avg_local_formated,clustering_global,clustering_global_formated,k_core_max,k_core_max_formated,clique_bound_max,clique_bound_max_formated,size,size_formated" > $OUTPUT

# one line for each row
sed "s/<\/tr>/<\/tr>\n/g" scripts/networks/data/all_networks_html.txt |
    # remove random networks
    sed "/rand<\/td>/d" |
    # remove install.log pseudo network
    sed "/install.log/d" |
    # reduce to relevant matches
    grep -o "sortValue: [0-9.-]*\|[ 0-9a-zA-Z.-]*</td>\|</i>&nbsp; [^<>]*</a>" |
    # remove html stuff
    sed "s/sortValue: //g; s/<\/td>//g; s/<\/a>//g; s/<\/i>&nbsp; //g; /^$/d" |
    # create csv-lines
    paste -d "," - - - - - - - - - - - - - - - - - - - - - - - - - - - - |
    # replace not available values with NA
    sed "s/0,-/NA,-/g" >> $OUTPUT
    
