source("R/helper/load_helpers.R")

######################################################################
## selecting some graphs for the average distance tests

## read the data
tbl <- read_basic() %>% aggregate_generated()

## plot all graphs with n between 10k and 12k
plots <- main_plot(tbl %>%
    mutate(val = avg_deg) %>%
    filter(type == "generated" | (n < 12000 & n > 10000)),
point_size_scale = 3
)
ggplotly(plots$p2, tooltip = "text")

## selected graphs
graph_names <- c(
    "crack", "inlet", # local and homogeneous
    "socfb-Columbia2", "ca-HepPh", # local and heterogeneous
    "sinc15", "fd15", # non-local and homogeneous
    "escorts", "air03" # non-local and heterogeneous
)

## basic information about the selected graphs
tbl_basic <- tbl %>%
    filter(graph %in% graph_names) %>%
    select(graph, n, m, loc, het)

tbl <- tbl[tbl$graph %in% graph_names, ]
tbl_basic <- tbl[, c("graph", "n", "m", "loc", "het")]

######################################################################
## testing average distance algorithms

## prepare the (unaggregated) data
tbl <- tbl_basic %>%
    also(read_avg_dist_tests()) %>%
    group_by(graph) %>%
    ## column for exact avg_dist
    mutate(avg_dist_exact = max(ifelse(algo == "exact", avg_dist, 0))) %>%
    filter(algo != "exact") %>%
    ungroup() %>%
    ## sort by graph
    mutate(graph = factor(graph, levels = graph_names)) %>%
    arrange(graph) %>%
    ## additional stats
    group_by(graph, algo, sample_size) %>%
    mutate(
        avg_actual_sample_size = mean(actual_sample_size),
        avg_time = mean(time_avg_dist),
        rel_error_signed = (avg_dist - avg_dist_exact) / avg_dist_exact,
        rel_error = abs(rel_error_signed)
    ) %>%
    ungroup()

## table for the parameters we use
tbl_print <- tbl %>%
    filter(algo == "weighted" & sample_size == 400) %>%
    group_by(graph) %>%
    summarize(
        "$n$" = mean(n),
        "$m$" = mean(m),
        loc = mean(loc),
        het = mean(het),
        "avg dist" = mean(avg_dist_exact),
        min = min(avg_dist),
        max = max(avg_dist),
        error = median(rel_error)
    ) %>%
    ungroup() %>%
    as.data.frame() %>%
    sanitize_table(c(
        sanitize_text,
        sanitize_number(1),
        sanitize_number(1),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_number(0.01),
        sanitize_percent(0.01)
    ))

xtbl <- xtable(tbl_print, align = "llrrrrrrrr")
print(xtbl,
    include.rownames = FALSE,
    booktabs = TRUE,
    floating = FALSE,
    sanitize.colnames.function = function(str) str,
    sanitize.text.function = function(str) str,
    file = "R/output/avg_dist_comp_tbl.tex"
)


## comparison: with and without correction
p <- ggplot(
    tbl %>%
        filter(algo %in% c("weighted", "weighted_no_correct")) %>%
        mutate(algo = factor(algo,
            levels = c("weighted_no_correct", "weighted")
        )) %>%
        arrange(algo),
    aes(
        x = as.factor(sample_size),
        y = rel_error,
        fill = algo,
        group = paste(sample_size, algo)
    )
) +
    geom_boxplot(width = 0.5, outlier.size = 0.3) +
    facet_wrap(~graph, nrow = 2) +
    scale_y_log10(labels = scales::percent_format(drop0trailing = TRUE)) +
    xlab("k (roughly the sample size)") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    ylab("relative error") +
    scale_fill_manual(
        labels = c("original", "improved (conditioning on |S|)"),
        values = c(green, blue)
    ) +
    theme(legend.position = "top", legend.title = element_blank())
create_pdf("R/output/avg_dist_comp_correction.pdf", p, height = 0.6)

## comparison: weighted and uniform
p <- ggplot(
    tbl %>% filter(
        algo %in% c("weighted", "uniform"),
        sample_size <= 800
    ),
    aes(
        x = as.factor(sample_size),
        y = rel_error,
        fill = algo,
        group = paste(algo, sample_size)
    )
) +
    geom_boxplot(width = 0.5, outlier.size = 0.3) +
    facet_wrap(~graph, nrow = 2) +
    scale_y_log10(labels = scales::percent_format(drop0trailing = TRUE)) +
    xlab("k (roughly the sample size)") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    ylab("relative error") +
    scale_fill_manual(values = c(red, blue)) +
    theme(legend.position = "top", legend.title = element_blank())
create_pdf("R/output/avg_dist_comp.pdf", p, height = 0.6)

## actual sample size of weighted sampling
tbl_w <- tbl[tbl$algo == "weighted", ]
tbl_w$rel_sample_size <- tbl_w$actual_sample_size / tbl_w$sample_size

tbl %>%
    filter(algo == "weighted") %>%
    summarize(rel_sample_size = mean(actual_sample_size / sample_size))

msg(sprintf(
    "actual sample size / parameter k for weighted sampling: %f",
    tbl %>%
        filter(algo == "weighted") %>%
        summarize(rel_sample_size = mean(actual_sample_size / sample_size))
))
msg("")

## weighted vs. uniform: run time
tbl_time <- tbl[tbl$algo %in% c("weighted", "uniform"), ]
p <- ggplot(
    tbl %>% filter(algo %in% c("weighted", "uniform")),
    aes(
        x = time_avg_dist,
        y = rel_error,
        color = algo
    )
) +
    geom_point(size = 0.1, alpha = 0.5) +
    facet_wrap(~graph, nrow = 2) +
    scale_y_log10(labels = scales::percent_format(drop0trailing = TRUE)) +
    scale_x_log10() +
    xlab("time (ms)") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    ylab("relative error") +
    scale_color_manual(values = c(red, blue)) +
    guides(colour = guide_legend(override.aes = list(size = 2, alpha = 1))) +
    theme(legend.position = "top", legend.title = element_blank())
create_pdf("R/output/avg_dist_comp_time.pdf", p, height = 0.6)
