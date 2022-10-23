also <- function(tbl1, tbl2) {
    #' join two tables by graph
    left_join(tbl1, tbl2, by = "graph")
}


read <- function(name) {
    #' read csv file in output data folder
    read.csv(paste0("output_data/", name, ".csv"))
}

read_basic <- function() {
    #' read basic information we always need
    basic_tbl <- read_edge_locality() %>%
        also(read_deg_distr()) %>%
        also(read_gen_args()) %>%
        add_graph_types() %>%
        add_graph_types_detailed() %>%
        add_is_dense() %>%
        add_is_tree() %>%
        add_is_actually_gen() %>%
        filter(!is_dense & !is_tree & !is_gen) %>%
        select(-is_dense, -is_tree, -is_gen)
    basic_tbl
}

def_simple_read <- function(name) {
    #' define read function that just reads the csv
    assign(paste0("read_", name), function() {
        read(name)
    }, envir = .GlobalEnv)
}


for (name in c(
    "clustering_coeff", "vertex_cover_dominance",
    "closure", "closure_weak", "degeneracy",
    "louvain", "diameter_bounds", "diameter_exact", "avg_dist_tests"
)) {
    def_simple_read(name)
}


read_cliques <- function() {
    read("cliques") %>%
        mutate(across(where(is.numeric), ~ ifelse(nr_cliques == 0, NA, .x)))
}

read_coloring <- function() {
    read("coloring") %>%
        mutate(across(where(is.numeric), ~ ifelse(remaining_n == -1, NA, .x)))
}

read_diameter_exact <- function() {
    read("diameter_exact") %>%
        mutate(across(where(is.numeric), ~ ifelse(diameter == 0, NA, .x)))
}

read_dist <- function() {
    read("dist") %>%
        select(graph, algo, time_dist, search_space, dist) %>%
        group_by(graph, algo) %>%
        summarize_all(mean) %>%
        ungroup()
}


read_edge_locality <- function() {
    read("size") %>%
        also(read("avg_detour_dist")) %>%
        also(read("avg_deg_locality")) %>%
        also(read("avg_dist") %>% select(graph, avg_dist)) %>%
        mutate(
            non_edges = n * (n - 1) / 2 - m,
            avg_non_edge_dist =
                pmax(avg_dist + m / non_edges * (avg_dist - 1), 2),
            avg_dist_locality = ifelse(avg_non_edge_dist == 2, 0,
                1 - (avg_detour_dist - 2) / (avg_non_edge_dist - 2)
            ),
            avg_dist_locality_cap = pmax(avg_dist_locality, 0),
            avg_edge_locality = (avg_deg_locality + avg_dist_locality_cap) / 2,
            loc = avg_edge_locality
        ) %>%
        select(
            graph, avg_edge_locality, avg_deg_locality,
            avg_dist_locality, avg_dist_locality_cap,
            avg_detour_dist, avg_non_edge_dist, avg_dist, loc
        )
}


read_deg_distr <- function() {
    read("deg_distr") %>%
        group_by(graph) %>%
        summarize(
            n = sum(frequency),
            m = sum(frequency * degree / 2),
            avg_deg = m * 2 / n,
            max_deg = max(degree),
            deg_var = sum(frequency * (degree - avg_deg)^2 / n),
            deg_coeff_of_variation = sqrt(deg_var) / avg_deg,
            deg_1_count = sum(ifelse(degree == 1, frequency, 0)),
            deg_2_count = sum(ifelse(degree == 2, frequency, 0)),
            het = log10(deg_coeff_of_variation)
        ) %>%
        ungroup()
}


read_gen_args <- function() {
    read("girg_attributes") %>%
        bind_rows(read("cl_attributes")) %>%
        bind_rows(read("er_attributes")) %>%
        select(
            graph,
            gen_n = n, gen_deg = deg, gen_dim = dim, gen_ple = ple,
            gen_T = T, gen_square = square
        )
}


add_graph_types_detailed <- function(tbl) {
    tbl %>%
        left_join(
            read.csv("scripts/networks/data/all_networks.csv") %>%
                select(graph = name, type_detailed = type) %>%
                filter(!duplicated(graph)),
            by = "graph"
        ) %>%
        mutate(type_detailed = case_when(
            grepl("girg_n", graph) ~ "girg",
            grepl("cl_n", graph) ~ "cl",
            grepl("er_n", graph) ~ "er",
            is.na(type_detailed) ~ "unknown",
            TRUE ~ type_detailed
        ))
}


add_graph_types <- function(tbl) {
    tbl %>%
        mutate(type = case_when(
            grepl("er_n|cl_n|girg_n", graph) ~ "generated",
            grepl("girg_deg_scaling_n", graph) ~ "girg_deg_scaling",
            TRUE ~ "real"
        ))
}


aggregate_generated <- function(tbl) {
    tbl %>%
        mutate(graph = sub("_seed=[0-9]*", "", graph)) %>%
        group_by(across(!where(is.numeric))) %>%
        summarise_all(mean) %>%
        ungroup()
}


add_is_dense <- function(tbl) {
    #' tag networks that are too dense (density at least 0.1)
    tbl %>% mutate(is_dense = m / choose(n, 2) >= 0.1)
}


add_is_tree <- function(tbl) {
    #' tag networks that are trees
    tbl %>% mutate(is_tree = (m == n - 1))
}


add_is_actually_gen <- function(tbl) {
    #' tag "real-world" networks that are actually generated
    pattern <- paste(
        ## form DIMACS challenge; seem generated; mostly rather dense
        ## (https://networkrepository.com/dimacs.php)
        "^c[0-9]", "^dsjc", "^mann", "brock[0-9]", "^c-fat", "^gen[0-9][0-9]",
        "^keller", "p-hat[0-9]", "san[0-9]", "sanr[0-9]",
        ## in the category of generated graphs
        ## (https://networkrepository.com/rand.php)
        "^cl", "^sw-", "^ba-", "^rgg_n",
        ## probably random
        "^er-avg", "^g[0-9]+$",
        ## symmetric powers of "08blocks" graph
        ## (https://hpac.imag.fr/Matrices/SPG/)
        ## (https://hpac.imag.fr/Matrices/SPG/sympower.html)
        "^EX[1-6]$",
        sep = "|"
    )
    tbl %>% mutate(is_gen = (type == "real") &
        grepl(pattern, graph, ignore.case = TRUE))
}

het_extreme_min <- -1.0
het_extreme_max <- 1.5

graph_filter <- function(tbl, rm_torus = FALSE, rm_square = FALSE,
                         rm_deg_10 = FALSE, rm_deg_20 = FALSE,
                         rm_deg_scaling = FALSE, rm_het_extreme = FALSE) {
    tbl %>%
        mutate(
            tmp_torus = !is.na(gen_square) & !gen_square,
            tmp_square = !is.na(gen_square) & gen_square,
            tmp_deg_10 = (type == "generated") & (gen_deg == 10),
            tmp_deg_20 = (type == "generated") & (gen_deg == 20),
            tmp_scaling = (type == "girg_deg_scaling"),
            tmp_het_extreme = (het < het_extreme_min | het > het_extreme_max)
        ) %>%
        filter(
            !(rm_torus & tmp_torus) &
                !(rm_square & tmp_square) &
                !(rm_deg_10 & tmp_deg_10) &
                !(rm_deg_20 & tmp_deg_20) &
                !(rm_deg_scaling & tmp_scaling) &
                !(rm_het_extreme & tmp_het_extreme)
        ) %>%
        select(-starts_with("tmp_"))
}
