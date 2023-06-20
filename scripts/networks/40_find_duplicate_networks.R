library(igraph)
source("R/helper/load_helpers.R")

potential_duplicates <- function() {
    ## Read a bunch of statistics for the graphs and group the graphs
    ## with equal statistics.  Returns a list of vectors of graph
    ## names, each vector representing a group.
    tbl <- read_deg_distr() %>% also(read_clustering_coeff())
    tbl_dup <- aggregate(
        graph ~ n + m + clustering_coeff + deg_1_count +
            deg_2_count + avg_deg + max_deg + deg_var +
            deg_coeff_of_variation,
        tbl,
        FUN = paste
    )
    tbl_dup[grepl(",", tbl_dup$graph), ]$graph
}

is_isom <- function(name1, name2) {
    ## Check for two graph names whether the graphs are isomorphic.
    ## Returns TRUE or FALSE accordingly.
    print(paste("checking for isomorphism:", name1, name2))
    dir <- "input_data/edge_list/"
    f1 <- paste0(dir, name1)
    f2 <- paste0(dir, name2)
    if (isTRUE(all.equal(readLines(f1), readLines(f2)))) {
        return(TRUE)
    }
    g1 <- read_graph(f1, "edgelist", directed = FALSE)
    g2 <- read_graph(f2, "edgelist", directed = FALSE)
    graph.isomorphic(g1, g2)
}

split_by_comparison <- function(vector, comparator) {
    ## Splits the elements of a vector into groups, where each group
    ## is the equivalence class with respect to an equivalence
    ## relation given by the comparator.  Returns a list of vectors,
    ## each representing a group.
    res <- list()
    for (elt1 in vector) {
        group_found <- FALSE
        for (i in seq_len(length(res))) {
            elt2 <- res[[i]][1]
            if (comparator(elt1, elt2)) {
                group_found <- TRUE
                res[[i]] <- c(res[[i]], elt1)
                break;
            }
        }
        if (!group_found) {
            res <- append(res, elt1)
        }
    }
    res
}

duplicate_groups <- function() {
    cache_filename <- "scripts/networks/data/duplicate_network_groups.RDS"
    if (file.exists(cache_filename)) {
        return(readRDS(cache_filename))
    } else {
        dup <- potential_duplicates()

        real_dup <- unlist(lapply(dup, function(x) split_by_comparison(x, is_isom)),
            recursive = FALSE
        )

        real_dup_ids <- which(sapply(real_dup, length) > 1)
        dup_groups <- real_dup[real_dup_ids]

        saveRDS(dup_groups, file = cache_filename)
        return(dup_groups)
    }
}

## create the duplicate groups and load the table of all networks
dup_groups <- duplicate_groups()
tbl <- read.csv("scripts/networks/data/all_networks.csv")[, c("name", "type")]

## add types to the network names
dup_groups <- lapply(dup_groups, FUN = function(x)
    left_join(data.frame(name = x), tbl, by = "name", multiple = "first"))

## sort by type
dup_groups <- lapply(dup_groups, FUN = function(x) {
    if (nrow(x[x$type == "misc" & !is.na(x$type), ]) > 0) {
        x[x$type == "misc" & !is.na(x$type), ]$type <- "zzzmisc"
    }
    if (nrow(x[x$type == "dynamic" & !is.na(x$type), ]) > 0) {
        x[x$type == "dynamic" & !is.na(x$type), ]$type <- "zzdynamic"
    }
    x[order(x$type, x$name), ]
})

## keep the first and remove the rest
keep <- sapply(dup_groups, FUN = function(x) x$name[1])
remove <- unlist(sapply(dup_groups, FUN = function(x) x$name[-1]))

write.table(remove, file = "scripts/networks/data/duplicates.txt",
            row.names = FALSE, col.names = FALSE)

write.table(keep, file = "scripts/networks/data/keep.txt",
            row.names = FALSE, col.names = FALSE)

