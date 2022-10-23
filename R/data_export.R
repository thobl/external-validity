source("R/helper/load_helpers.R")


######################################################################
## read basic properties and output some stats on real-world networks

## graph, type, type_detailed, filtered, n, m, deg_avg, deg_max,
## deg_var, deg_coeff_of_var, heterogeneity, locality,
## loc_avg_deg_loc, loc_avg_dist_loc_nocap, loc_avg_dist_loc,
## loc_avg_detour_dist, loc_avg_non_edge_dist, avg_dist,
## clustering_coeff,
tbl <- read_deg_distr() %>%
    also(read_edge_locality()) %>%
    also(read_clustering_coeff()) %>%
    add_graph_types() %>%
    add_graph_types_detailed() %>%
    add_is_dense() %>%
    add_is_tree() %>%
    add_is_actually_gen() %>%
    mutate(filtered = (is_gen | is_tree | is_dense))

msg(sprintf(
    "Total number of networks from Network Repository: %d",
    tbl %>% filter(type == "real") %>% nrow()
))
msg(sprintf(
    "Removed %d generated networks.",
    tbl %>% filter(is_gen) %>% nrow()
))
msg(sprintf(
    "Removed %d trees.",
    tbl %>% filter(is_tree, !is_gen) %>% nrow()
))
msg(sprintf(
    "Removed %d dense networks (density ≥ 0.1).",
    tbl %>% filter(is_dense, !is_gen, !is_tree) %>% nrow()
))
msg(sprintf(
    "Result: %d removed, %d remaining.",
    tbl %>% filter(filtered) %>% nrow(),
    tbl %>% filter(!filtered, type == "real") %>% nrow()
))

msg(sprintf(
    "Extreme heterogeneity: %d below lower threshold, %d above higher threshold.",
    tbl %>% filter(!filtered, type == "real", het < het_extreme_min) %>% nrow(),
    tbl %>% filter(!filtered, type == "real", het > het_extreme_max) %>% nrow()
))

tbl <- tbl %>%
    select(
        graph, type, type_detailed, filtered, n, m,
        deg_avg = avg_deg,
        deg_max = max_deg,
        deg_var,
        deg_coeff_of_var = deg_coeff_of_variation,
        heterogeneity = het,
        locality = loc,
        loc_avg_deg_loc = avg_deg_locality,
        loc_avg_dist_loc_nocap = avg_dist_locality,
        loc_avg_dist_loc = avg_dist_locality_cap,
        loc_avg_detour_dist = avg_detour_dist,
        loc_avg_non_edge_dist = avg_non_edge_dist,
        avg_dist,
        clustering_coeff
    )

######################################################################
## BFS

## bfs_bbi_time, bfs_bbi_search_space, bfs_sbi_time,
## bfs_sbi_search_space, bfs_uni_time, bfs_uni_search_space,
## bfs_avg_dist,

tbl_bfs <- read_dist() %>%
    tidyr::pivot_wider(
        names_from = algo,
        values_from = c(search_space, time_dist)
    ) %>%
    select(graph,
        bfs_bbi_time = time_dist_bfs_bi_balanced,
        bfs_bbi_search_space = search_space_bfs_bi_balanced,
        bfs_sbi_time = time_dist_bfs_bi_always_swap,
        bfs_sbi_search_space = search_space_bfs_bi_always_swap,
        bfs_uni_time = time_dist_bfs,
        bfs_uni_search_space = search_space_bfs,
        bfs_avg_dist = dist
    )

tbl <- tbl %>% also(tbl_bfs)

######################################################################
## cliques, coloring

tbl <- tbl %>%
    also(
        ## clique_count, clique_largest, clique_time,
        read_cliques() %>%
            select(graph,
                clique_count = nr_cliques,
                clique_largest = max_clique,
                clique_time = time_cliques
            )
    ) %>%
    also(
        ## color_kernel_n, color_kernel_m, color_clique_time, color_time,
        read_coloring() %>%
            select(graph,
                color_kernel_n = remaining_n,
                color_kernel_m = remaining_m,
                color_clique_time = time_cliques,
                color_time = time_coloring
            )
    )


######################################################################
## diameter

## diam_doub_sweep_lower_bound, diam_doub_sweep_upper_bound,
## diam_doub_sweep_time, diam_four_sweep_lower_bound,
## diam_four_sweep_upper_bound, diam_four_sweep_time,
tbl_diam_bounds <- read_diameter_bounds() %>%
    tidyr::pivot_wider(
        names_from = algo,
        values_from = c(lower_bound, upper_bound, time_diameter_bounds)
    ) %>%
    select(graph,
        diam_doub_sweep_lower_bound = lower_bound_double_sweep,
        diam_doub_sweep_upper_bound = upper_bound_double_sweep,
        diam_doub_sweep_time = time_diameter_bounds_double_sweep,
        diam_four_sweep_lower_bound = lower_bound_four_sweep,
        diam_four_sweep_upper_bound = upper_bound_four_sweep,
        diam_four_sweep_time = time_diameter_bounds_four_sweep
    )

## diam_ifub_hd_bfs_count, diam_ifub_hd_time,
## diam_ifub_four_bfs_count, diam_ifub_four_time, diameter,
tbl_diam_exact <- read_diameter_exact() %>%
    tidyr::pivot_wider(
        names_from = algo,
        values_from = c(bfs_count, time_diameter_exact)
    ) %>%
    select(graph,
        diam_ifub_hd_bfs_count = bfs_count_ifub_hd,
        diam_ifub_hd_time = time_diameter_exact_ifub_hd,
        diam_ifub_four_bfs_count = bfs_count_ifub_foursweephd,
        diam_ifub_four_time = time_diameter_exact_ifub_foursweephd,
        diameter,
    )

tbl <- tbl %>%
    also(tbl_diam_bounds) %>%
    also(tbl_diam_exact)


######################################################################
## louvain, vertex cover, closure, degeneracy
tbl <- tbl %>%
    also(
        ## louvain_iterations, louvain_time,
        read_louvain() %>%
            select(graph,
                louvain_iterations = iterations_louvain,
                louvain_time = time_louvain
            )
    ) %>%
    also(
        ## vc_dominant, vc_kernel_non_isolated, vc_kernel_nr_comp,
        ## vc_kernel_largest_comp, vc_time,
        read_vertex_cover_dominance() %>%
            select(graph,
                vc_dominant = dominant,
                vc_kernel_non_isolated = remaining_non_isolated,
                vc_kernel_nr_comp = nr_components,
                vc_kernel_largest_comp = largest_component,
                vc_time = time_vc_dominance
            )
    ) %>%
    ## closure, closure_weak, closure_weak_time, degeneracy
    also(read_closure()) %>%
    also(read_closure_weak() %>%
        rename(closure_weak_time = time_closure_weak)) %>%
    also(read_degeneracy())


######################################################################
## write to file
tbl_real <- tbl %>% filter(type == "real")
tbl_gen <- tbl %>%
    filter(type == "generated") %>%
    also(read_gen_args())

write.csv(tbl_real, "R/output/data_export_real.csv", row.names = FALSE)
write.csv(tbl_gen, "R/output/data_export_gen.csv", row.names = FALSE)
write.csv(tbl, "R/output/data_export.csv", row.names = FALSE)
