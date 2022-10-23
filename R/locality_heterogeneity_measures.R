source("R/helper/load_helpers.R")

######################################################################
## read the data
tbl <- read_basic() %>%
    also(read_clustering_coeff()) %>%
    filter(type == "real")


######################################################################
## density plot
p <- ggarrange(
    ggplot(tbl, aes(x = het)) +
        geom_density() +
        geom_vline(xintercept = het_extreme_min, size = 0.15) +
        geom_vline(xintercept = het_extreme_max, size = 0.15) +
        xlab("heterogeneity"),
    ggplot(tbl, aes(x = avg_deg_locality)) +
        geom_density() +
        xlab("degree locality") +
        rremove("ylab"),
    ggplot(tbl, aes(x = avg_dist_locality_cap)) +
        geom_density() +
        xlab("distance locality") +
        rremove("ylab"),
    ggplot(tbl, aes(x = loc)) +
        geom_density() +
        xlab("locality") +
        rremove("ylab"),
    nrow = 1
)
create_pdf("R/output/locality_heterogeneity_density.pdf", p, height = 0.2)


######################################################################
## comparison of different locality plots
comp_plot <- function(y, ylab) {
    ggplot(tbl, aes(x = clustering_coeff, y = get(y))) +
        geom_point(alpha = 0.1, size = 0.5) +
        xlab("clustering coefficient") +
        ylab(ylab)
}
p <- ggarrange(
    comp_plot("avg_deg_locality", "degree locality"),
    comp_plot("avg_dist_locality_cap", "distance locality"),
    comp_plot("loc", "locality"),
    nrow = 1
)
create_pdf("R/output/locality_heterogeneity_clustering.pdf", p, height = 0.31)


######################################################################
## networks with negative distance locality
msg(sprintf(
    "nr of networks with average distance locality < 0: %d",
    tbl %>% filter(avg_dist_locality < 0) %>% nrow()
))
msg(sprintf(
    "nr of networks with average distance locality < -0.1: %d",
    tbl %>% filter(avg_dist_locality < -0.1) %>% nrow()
))
msg(sprintf(
    "nr of networks with average non-edge distance 2: %d",
    tbl %>% filter(avg_non_edge_dist <= 2) %>% nrow()
))
msg("")

tbl_print <- tbl %>%
    filter(avg_dist_locality < -0.1 | avg_non_edge_dist <= 2) %>%
    arrange(avg_non_edge_dist) %>%
    select(
        "graph" = graph,
        "$n$" = n,
        "$m$" = m,
        "$\\dist(E\\cup\\overline{E})$" = avg_dist,
        "$\\dist(\\overline{E})$" = avg_non_edge_dist,
        "$\\dist^+(E')$" = avg_detour_dist,
        "$\\distloc{G}$" = avg_dist_locality,
        "$\\degloc{G}$" = avg_deg_locality
    ) %>%
    as.data.frame() %>%
    sanitize_table(c(
        sanitize_text,
        sanitize_number(1),
        sanitize_number(1),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_number(0.01)
    ))

xtbl <- xtable(tbl_print, align = "llrrrrrrr")
print(xtbl,
    include.rownames = FALSE,
    booktabs = TRUE,
    floating = FALSE,
    sanitize.colnames.function = function(str) str,
    sanitize.text.function = function(str) str,
    file = "R/output/neg_locality_tbl.tex"
)
