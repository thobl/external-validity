source("R/helper/load_helpers.R")

######################################################################
## common options
val <- "exponent x"
colors <- c(blue, green, yellow, red)


######################################################################
## read the data
tbl_non_aggr <- read_basic() %>%
    also(read_coloring()) %>%
    also(read_cliques()) %>%
    also(read_degeneracy()) %>%
    mutate(val = log(pmax(remaining_n, 1), base = n))
tbl <- tbl_non_aggr %>% aggregate_generated()


######################################################################
## remove timeouts
msg(sprintf(
    "number of networks with timeout: %d",
    tbl %>% filter(is.na(val)) %>% nrow()
))
tbl <- tbl %>% filter(!is.na(val))


######################################################################
## main pdf plots

## average degree 10
plots <- main_plot(
    tbl %>% graph_filter(
        rm_square = TRUE,
        rm_deg_20 = TRUE,
        rm_deg_scaling = TRUE,
        rm_het_extreme = TRUE
    ),
    val_title = val, val_colors = colors
)
create_pdf("R/output/coloring.pdf", plots$p)

## average degree 20
plots <- main_plot(
    tbl %>% graph_filter(
        rm_square = TRUE,
        rm_deg_10 = TRUE,
        rm_deg_scaling = TRUE,
        rm_het_extreme = TRUE
    ),
    val_title = val, val_colors = colors
)
create_pdf("R/output/coloring_high_avg_deg.pdf", plots$p)
create_pdf("R/output/coloring_high_avg_deg_gen.pdf",
    plots$p1 + theme(legend.position = "none"),
    width = 0.375, height = 0.363
)

######################################################################
## extreme heterogeneity pdf plots

p_extreme <- mid_plot_with_extreme(tbl %>% graph_filter(
    rm_square = TRUE,
    rm_deg_20 = TRUE,
    rm_deg_scaling = TRUE
), val_title = val, val_colors = colors)
create_pdf("R/output/coloring_full.pdf", p_extreme, width = 0.45)


p_extreme_high <- mid_plot_with_extreme(tbl %>% graph_filter(
    rm_square = TRUE,
    rm_deg_10 = TRUE,
    rm_deg_scaling = TRUE
), val_title = val, val_colors = colors)
create_pdf("R/output/coloring_high_avg_deg_full.pdf", p_extreme_high, width = 0.45)


######################################################################
## comparison between square and torus
p <- girg_plot(tbl %>% graph_filter(rm_deg_20 = TRUE),
    val_title = val, val_colors = colors
)
create_pdf("R/output/coloring_torus_square.pdf", p, width = 0.66)


######################################################################
## plotly plots
plots <- main_plot(
    tbl %>% graph_filter(
        rm_square = TRUE, rm_deg_20 = TRUE, rm_deg_scaling = TRUE, rm_het_extreme = TRUE
    ),
    val_title = val, val_colors = colors, point_size_scale = 3
)
ggplotly(plots$p1, tooltip = "text")
ggplotly(plots$p2, tooltip = "text")
ggplotly(plots$p3, tooltip = "text")


######################################################################
## scaling of the average degree in girgs
scaling_plot <- ggplot(
    tbl %>% filter(type == "girg_deg_scaling"),
    aes(x = avg_deg, y = val, color = loc, group = gen_T)
) +
    geom_point() +
    geom_line() +
    xlab("average degree") +
    ylab(val) +
    scale_color_gradientn(name = "locality", colors = c(red, violet, blue)) +
    theme(legend.key.width = unit(0.35, "cm"))
create_pdf("R/output/coloring_girg_scaled.pdf", scaling_plot,
    width = 0.55, height = 0.33
)


######################################################################
# max clique size and degeneracy

## prepare some data
tbl_clean <- tbl %>%
    graph_filter(
        rm_square = TRUE,
        rm_deg_20 = TRUE, rm_deg_scaling = TRUE
    ) %>%
    mutate(
        val_clique = log(max_clique, base = n),
        val_degen = log(degeneracy, base = n)
    )
val <- "exponent x"
colors <- c(green, yellow, red, purple)
val_limits <- c(
    min(tbl_clean %>% select(val_clique, val_degen)),
    max(tbl_clean %>% select(val_clique, val_degen))
)

## clique
plots <- main_plot(
    tbl_clean %>% mutate(val = val_clique) %>% graph_filter(rm_het_extreme = TRUE),
    val_title = val, val_colors = colors, val_limits = val_limits
)
create_pdf("R/output/cliques_max_clique.pdf", plots$p)

## clique with extreme heterogeneity

p_max_clique_extreme <- mid_plot_with_extreme(tbl_clean %>% mutate(val = val_clique),
    val_title = val, val_colors = colors, val_limits = val_limits
)
create_pdf("R/output/cliques_max_clique_full.pdf", p_max_clique_extreme, width = 0.45)

plots <- main_plot(
    tbl_clean %>% mutate(val = val_clique) %>% graph_filter(rm_het_extreme = TRUE),
    val_title = val, val_colors = colors, val_limits = val_limits,
    no_legend = TRUE
)
create_pdf("R/output/cliques_max_clique_noleg.pdf", plots$p, height = 0.364)

## degeneracy
plots <- main_plot(
    tbl_clean %>% mutate(val = val_degen) %>% graph_filter(rm_het_extreme = TRUE),
    val_title = val, val_colors = colors, val_limits = val_limits
)
create_pdf("R/output/degeneracy.pdf", plots$p)

p_degeneracy_extreme <- mid_plot_with_extreme(tbl_clean %>% mutate(val = val_degen),
    val_title = val, val_colors = colors, val_limits = val_limits
)
create_pdf("R/output/degeneracy_full.pdf", p_degeneracy_extreme, width = 0.45)

plots <- main_plot(
    tbl_clean %>% mutate(val = val_degen) %>% graph_filter(rm_het_extreme = TRUE),
    val_title = val, val_colors = colors, val_limits = val_limits,
    no_legend = TRUE
)
create_pdf("R/output/degeneracy_noleg.pdf", plots$p, height = 0.364)


######################################################################
## distribution
p <- ggplot(tbl %>% filter(type == "real"), aes(x = val)) +
    geom_density()
create_pdf("R/output/coloring_distribution.pdf", p,
    width = 0.5, height = 0.3
)


######################################################################
## additional data points for the variance on GIRGs
plots <- main_plot(
    tbl_non_aggr %>% graph_filter(
        rm_square = TRUE, rm_deg_10 = TRUE, rm_deg_scaling = TRUE
    ),
    val_title = val, val_colors = colors, point_size_scale = 3
)
ggplotly(plots$p1, tooltip = "text")

max_var <- tbl_non_aggr %>%
    graph_filter(rm_square = TRUE, rm_deg_10 = TRUE) %>%
    filter(type_detailed == "girg") %>%
    group_by(gen_T, gen_ple) %>%
    summarize(avg = mean(val), var = sum((val - avg)^2)) %>%
    ungroup() %>%
    filter(var == max(var))

values <- tbl_non_aggr %>%
    graph_filter(rm_square = TRUE, rm_deg_10 = TRUE) %>%
    filter(type_detailed == "girg", gen_T == max_var$gen_T, gen_ple == max_var$gen_ple) %>%
    pull(val)
msg(sprintf(
    "exponents (core size) for GIRG with average degree 20, ple = %s and T = %s (5 graphs): %s; average: %.2f",
    max_var$gen_ple, max_var$gen_T,
    paste(sort(round(values, 2)), collapse = ", "),
    mean(values)
))
