source("R/helper/load_helpers.R")

######################################################################
## common options
val <- "relative kernel size"
colors <- c(green, yellow, red)


######################################################################
## read the data
tbl <- read_basic() %>%
    also(read_vertex_cover_dominance()) %>%
    mutate(val = largest_component / n) %>%
    aggregate_generated() %>%
    filter_generated(rm_deg_20 = TRUE, rm_deg_scaling = TRUE)


######################################################################
## main pdf plots
plots <- main_plot(tbl %>% filter_generated(rm_square = TRUE),
    val_title = val, val_colors = colors
)
create_pdf("R/output/vertex_cover.pdf", plots$p)


######################################################################
## comparison between square and torus
p <- girg_plot(tbl, val_title = val, val_colors = colors)
create_pdf("R/output/vertex_cover_torus_square.pdf", p, width = 0.66)


######################################################################
## plotly plots
plots <- main_plot(tbl %>% filter_generated(rm_square = TRUE),
    val_title = val, val_colors = colors,
    point_size_scale = 3
)
ggplotly(plots$p1, tooltip = "text")
ggplotly(plots$p2, tooltip = "text")
ggplotly(plots$p3, tooltip = "text")


######################################################################
## some additional interesting numbers
tbl_real <- tbl %>% filter(type == "real")
msg(sprintf(
    "fraction of networks reduced to < 0.05: %f",
    nrow(tbl_real[tbl_real$val < 0.05, ]) / nrow(tbl_real)
))
msg(sprintf(
    "fraction of networks reduced to < 0.95: %f",
    nrow(tbl_real[tbl_real$val > 0.95, ]) / nrow(tbl_real)
))
msg(sprintf(
    "fraction of networks with reduction between 0.05 and 0.95: %f",
    nrow(tbl_real[tbl_real$val <= 0.95 & tbl_real$val >= 0.05, ]) /
        nrow(tbl_real)
))
msg("")


######################################################################
## density plot
ggplot(tbl_real, aes(x = val)) +
    geom_density()
