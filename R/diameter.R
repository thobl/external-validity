source("R/helper/load_helpers.R")

######################################################################
## read the data
tbl_non_aggr <- read_basic() %>%
    also(read_diameter_exact()) %>%
    graph_filter(rm_deg_20 = TRUE, rm_deg_scaling = TRUE) %>%
    mutate(val = log(bfs_count, base = n))
tbl <- tbl_non_aggr %>% aggregate_generated()

######################################################################
## remove and report timeouts
for (alg in unique(tbl$algo)) {
    msg(sprintf("algo type %s:", alg))
    msg(sprintf(
        "%d real-world networks with timeout",
        tbl %>% filter(type == "real", algo == alg, is.na(diameter)) %>% nrow()
    ))
    msg(sprintf(
        "%d generated networks with timeout",
        tbl %>% filter(type == "generated", algo == alg, is.na(diameter)) %>% nrow()
    ))
    msg("")
}
tbl <- tbl %>% filter(!is.na(diameter))


######################################################################
## common options
val <- "exponent x"
colors <- c(blue, green, yellow, red)
val_limits <- c(tbl %>% pull(val) %>% min(), tbl %>% pull(val) %>% max())


######################################################################
## main pdf plots

## ifub_foursweephd
plots <- main_plot(tbl %>%
    graph_filter(rm_torus = TRUE, rm_het_extreme = TRUE) %>%
    filter(algo == "ifub_foursweephd"),
val_title = val, val_colors = colors, val_limits = val_limits
)
create_pdf("R/output/diameter_ifub_foursweephd.pdf", plots$p)

## ifub_foursweephd with extreme heterogeneity
p_extreme <- mid_plot_with_extreme(tbl %>%
    graph_filter(rm_torus = TRUE) %>%
    filter(algo == "ifub_foursweephd"),
val_title = val, val_colors = colors, val_limits = val_limits
)
create_pdf("R/output/diameter_ifub_foursweephd_full.pdf", p_extreme, width = 0.45)


## ifub_foursweephd without legend
plots <- main_plot(tbl %>%
    graph_filter(rm_torus = TRUE, rm_het_extreme = TRUE) %>%
    filter(algo == "ifub_foursweephd"),
val_title = val, val_colors = colors, val_limits = val_limits, no_legend = TRUE
)
create_pdf("R/output/diameter_ifub_foursweephd_noleg.pdf", plots$p,
    height = 0.364
)

## ifub_hd
plots <- main_plot(tbl %>%
    graph_filter(rm_torus = TRUE, rm_het_extreme = TRUE) %>%
    filter(algo == "ifub_hd"),
val_title = val, val_colors = colors, val_limits = val_limits
)
create_pdf("R/output/diameter_ifub_hd.pdf", plots$p)

## ifub_hd with extreme heterogeneity
p_extreme_hd <- mid_plot_with_extreme(tbl %>%
    graph_filter(rm_torus = TRUE) %>%
    filter(algo == "ifub_hd"),
val_title = val, val_colors = colors, val_limits = val_limits
)
create_pdf("R/output/diameter_ifub_hd_full.pdf", p_extreme_hd, width = 0.45)


######################################################################
## comparison between square and torus

## ifub_foursweephd
p <- girg_plot(tbl %>% filter(algo == "ifub_foursweephd"),
    val_title = val, val_colors = colors, val_limits = val_limits
)
create_pdf("R/output/diameter_ifub_foursweephd_torus_square.pdf", p,
    width = 0.66
)

## ifub_foursweephd without legend
p <- girg_plot(tbl %>% filter(algo == "ifub_foursweephd"),
    val_title = val, val_colors = colors, val_limits = val_limits,
    no_legend = TRUE
)
create_pdf("R/output/diameter_ifub_foursweephd_torus_square_noleg.pdf", p,
    width = 0.66, height = 0.364
)

## ifub_hd
p <- girg_plot(tbl %>% filter(algo == "ifub_hd"),
    val_title = val, val_colors = colors, val_limits = val_limits
)
create_pdf("R/output/diameter_ifub_hd_torus_square.pdf", p,
    width = 0.66
)


######################################################################
## additional output concerning the variance
plots <- main_plot(
    tbl_non_aggr %>%
        graph_filter(rm_torus = TRUE, rm_het_extreme = TRUE) %>%
        filter(algo == "ifub_foursweephd"),
    val_title = val, val_colors = colors, val_limits = val_limits, point_size_scale = 3
)
ggplotly(plots$p1, tooltip = "text")

max_var <- tbl_non_aggr %>%
    graph_filter(rm_torus = TRUE) %>%
    filter(type_detailed == "girg", algo == "ifub_foursweephd") %>%
    group_by(gen_T, gen_ple) %>%
    summarise(avg = mean(val), var = sum((val - avg)^2)) %>%
    ungroup() %>%
    filter(var == max(var))

values <- tbl_non_aggr %>%
    graph_filter(rm_torus = TRUE) %>%
    filter(
        type_detailed == "girg",
        algo == "ifub_foursweephd",
        gen_ple == max_var$gen_ple, gen_T == max_var$gen_T
    ) %>%
    pull(val)

msg(sprintf(
    "exponents (ifub_foursweephd) for GIRG with ple = %s and T = %s (5 graphs): %s; average: %.2f",
    max_var$gen_ple, max_var$gen_T,
    paste(sort(round(values, 2)), collapse = ", "),
    mean(values)
))
msg("")


######################################################################
## stats on lower bounds
stats <- tbl %>%
    filter(type == "real") %>%
    group_by(graph) %>%
    summarize(diameter = max(diameter)) %>%
    ungroup() %>%
    also(read_diameter_bounds()) %>%
    filter(algo == "four_sweep") %>%
    summarize(
        exact = sum(diameter == lower_bound),
        diff_max_1 = sum(diameter <= lower_bound + 1),
        diff_max_2 = sum(diameter <= lower_bound + 2)
    )


msg(sprintf(
    "total real: %d",
    tbl %>% filter(type == "real") %>% pull(graph) %>% unique() %>% length()
))
msg(sprintf("four_sweep lb == diameter: %d", stats$exact))
msg(sprintf("four_sweep lb + 1 >= diameter: %d", stats$diff_max_1))
msg(sprintf("four_sweep lb + 2 >= diameter: %d", stats$diff_max_2))
msg("")
