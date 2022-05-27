source("R/helper/load_helpers.R")

######################################################################
## common options
val <- "iterations"
colors <- c(green, yellow, red, violet)


######################################################################
## read the data
tbl_non_aggr <- read_basic() %>%
    also(read_louvain()) %>%
    mutate(val = iterations_louvain) %>%
    filter_generated(rm_deg_20 = TRUE, rm_deg_scaling = TRUE)
tbl <- tbl_non_aggr %>% aggregate_generated()


######################################################################
## remove outliers
msg(sprintf(
    "removed outliers; graphs with at least 1000 iterations: %s",
    tbl %>% filter(val > 1000) %>% pull(val) %>% sort() %>%
        paste(collapse = ", ")
))
msg("")

tbl <- tbl %>% filter(val <= 1000)


######################################################################
## main pdf plots
plots <- main_plot(tbl %>% filter_generated(rm_square = TRUE),
    val_title = val, val_colors = colors,
    val_color_trans = "log10"
)
create_pdf("R/output/louvain.pdf", plots$p)


######################################################################
## comparison between square and torus
p <- girg_plot(tbl,
    val_title = val, val_colors = colors,
    val_color_trans = "log10"
)
create_pdf("R/output/louvain_torus_square.pdf", p, width = 0.66)


######################################################################
## plotly plots
plots <- main_plot(tbl_non_aggr %>% filter_generated(rm_square = TRUE),
    val_title = val, val_colors = colors,
    val_color_trans = "log10", point_size_scale = 3
)
ggplotly(plots$p1, tooltip = "text")
ggplotly(plots$p2, tooltip = "text")
ggplotly(plots$p3, tooltip = "text")


######################################################################
## additional info on distribution
er <- tbl_non_aggr %>%
    filter(type_detailed == "er") %>%
    pull(val)
cl_ple86 <- tbl_non_aggr %>%
    filter(type_detailed == "cl", gen_ple == 8.6) %>%
    pull(val)
tbl_girg <- tbl %>%
    filter_generated(rm_square = TRUE) %>%
    filter(type_detailed == "girg")

msg(sprintf(
    "iterations for ER (5 graphs): %s; average: %.2f",
    er %>% sort() %>% paste(collapse = ", "),
    mean(er)
))
msg(sprintf(
    "max avg. iterations for CL: %.2f",
    tbl %>% filter(type_detailed == "cl") %>% pull(val) %>% max()
))
msg(sprintf(
    "iterations for CL with ple 8.6 (5 graphs): %s; average: %.2f",
    cl_ple86 %>% sort() %>% paste(collapse = ", "),
    mean(cl_ple86)
))
msg(sprintf(
    "girg (aggregated) ranges from %.1f to %.1f",
    tbl_girg %>% pull(val) %>% min(),
    tbl_girg %>% pull(val) %>% max()
))
msg(sprintf(
    "%.4f of the girg configurations have at most 20 iterations",
    tbl_girg %>% filter(val <= 20) %>% nrow() / tbl_girg %>% nrow()
))
msg(sprintf(
    "%.4f of the real networks have at most 100 iterations",
    tbl %>% filter(type == "real", val <= 100) %>% nrow() / tbl %>%
        filter(type == "real") %>%
        nrow()
))
msg("")
