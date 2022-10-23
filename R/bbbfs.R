source("R/helper/load_helpers.R")


######################################################################
## common options
val <- "exponent x"
colors <- c(blue, green, yellow, red)


######################################################################
## read the data
tbl <- read_basic() %>%
    also(read_dist()) %>%
    filter(algo == "bfs_bi_balanced") %>%
    mutate(val = log(search_space, base = m)) %>%
    aggregate_generated() %>%
    graph_filter(rm_deg_20 = TRUE, rm_deg_scaling = TRUE)


######################################################################
## main pdf plots
plots <- main_plot(tbl %>% graph_filter(
    rm_square = TRUE,
    rm_het_extreme = TRUE
),
val_title = val, val_colors = colors
)
create_pdf("R/output/bbbfs.pdf", plots$p)

######################################################################
## extreme heterogeneity pdf plots

p_extreme <- mid_plot_with_extreme(tbl, val_title = val, val_colors = colors)
create_pdf("R/output/bbbfs_full.pdf", p_extreme, width = 0.45)

######################################################################
## comparison between square and torus
p <- girg_plot(tbl, val_title = val, val_colors = colors)
create_pdf("R/output/bbbfs_torus_square.pdf", p, width = 0.66)


######################################################################
## plotly plots
plots <- main_plot(tbl %>% graph_filter(
    rm_square = TRUE,
    rm_het_extreme = TRUE
),
val_title = val, val_colors = colors, point_size_scale = 3
)
ggplotly(plots$p1, tooltip = "text")
ggplotly(plots$p2, tooltip = "text")
ggplotly(plots$p3, tooltip = "text")
