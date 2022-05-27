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
    filter_generated(rm_deg_20 = TRUE, rm_deg_scaling = TRUE)


######################################################################
## main pdf plots
plots <- main_plot(tbl %>% filter_generated(rm_square = TRUE),
    val_title = val, val_colors = colors
)
create_pdf("R/output/bbbfs.pdf", plots$p)


######################################################################
## comparison between square and torus
p <- girg_plot(tbl, val_title = val, val_colors = colors)
create_pdf("R/output/bbbfs_torus_square.pdf", p, width = 0.66)


######################################################################
## plotly plots
plots <- main_plot(tbl %>% filter_generated(rm_square = TRUE),
    val_title = val, val_colors = colors, point_size_scale = 3
)
ggplotly(plots$p1, tooltip = "text")
ggplotly(plots$p2, tooltip = "text")
ggplotly(plots$p3, tooltip = "text")
