source("R/helper/load_helpers.R")

######################################################################
## common options
val <- "nr. cliques / m"

######################################################################
## read the data
tbl <- read_basic() %>%
    also(read_cliques()) %>%
    also(read_closure()) %>%
    also(read_closure_weak()) %>%
    also(read_degeneracy()) %>%
    mutate(val = nr_cliques / m) %>%
    aggregate_generated() %>%
    graph_filter(rm_deg_20 = TRUE, rm_deg_scaling = TRUE)

######################################################################
## output some stats
tbl %>% filter(is.na(val))
read_cliques() %>% filter(is.na(nr_cliques))

stats <- tbl %>%
    group_by(type) %>%
    summarize(
        total = sum(type == type),
        timeout = sum(is.na(nr_cliques)),
        max_m_cliques = sum(!is.na(nr_cliques) & nr_cliques <= m),
        more_cliques = sum(!is.na(nr_cliques) & nr_cliques > m)
    )

msg("stats on timeouts and networks with few or many cliques")
stats %>%
    colnames() %>%
    sapply(sprintf, fmt = "% 15s") %>%
    paste0() %>%
    msg()
stats %>%
    filter(type == "real") %>%
    sapply(sprintf, fmt = "% 15s") %>%
    paste0() %>%
    msg()
stats %>%
    filter(type == "generated") %>%
    sapply(sprintf, fmt = "% 15s") %>%
    paste0() %>%
    msg()
msg("")


######################################################################
## separate table into low (<= 1) and high (> 1) values
tbl_low <- tbl %>% filter(!is.na(val) & val <= 1)
tbl_high <- tbl %>% filter(!is.na(val) & val > 1)


######################################################################
## main pdf plots

plots <- main_plot(tbl_low %>% graph_filter(rm_square = TRUE, rm_het_extreme = TRUE),
    val_title = val
)
create_pdf("R/output/cliques.pdf", plots$p)


######################################################################
## extreme heterogeneity pdf plots

p_extreme <- mid_plot_with_extreme(tbl_low, val_title = val)
create_pdf("R/output/cliques_full.pdf", p_extreme, width = 0.45)


######################################################################
## comparison between square and torus
p <- girg_plot(tbl, val_title = val)
create_pdf("R/output/cliques_torus_square.pdf", p, width = 0.66)


######################################################################
## plotly plots
plots <- main_plot(tbl_low %>% graph_filter(rm_square = TRUE, rm_het_extreme = TRUE),
    val_title = val, point_size_scale = 3
)
ggplotly(plots$p1, tooltip = "text")
ggplotly(plots$p2, tooltip = "text")
ggplotly(plots$p3, tooltip = "text")


######################################################################
## correlation between different parameters and nr cliques
correllation_plot <- function(tbl, labels, color_transform = identity,
                              log_vars = c()) {
    colored_points <- function(data, mapping, ...) {
        ggplot(data = data, mapping = mapping) +
            geom_point(aes(color = color_transform(val)),
                alpha = 0.3, size = 0.7
            ) +
            scale_colour_gradientn(
                colors = c(green, yellow, red)
            )
    }

    p <- ggpairs(tbl,
        upper = list(
            continuous = wrap("cor",
                color = "black", size = 2.5,
                method = "spearman", use = "pairwise"
            )
        ),
        lower = list(
            continuous = colored_points
        ),
        columnLabels = labels
    )

    ## change background colors for correlation plot
    k <- ncol(tbl)
    palette <- colorRampPalette(c(red, "white", green))
    for (i in 1:(k - 1)) {
        for (j in (i + 1):k) {
            corr <- cor(tbl[i], tbl[j],
                method = "spearman", use = "pairwise"
            )
            fill <- palette(1000)[findInterval(corr, seq(-1, 1, length = 1000))]
            p[i, j] <- p[i, j] +
                theme(panel.background = element_rect(fill = fill))
        }
    }

    ## change to log axis for some columns + controlling the breaks
    x_log <- scale_x_log10(
        breaks = scales::log_breaks(n = 4),
        labels = scales::trans_format("log10", scales::math_format(10^.x))
    )
    y_log <- scale_y_log10(
        breaks = scales::log_breaks(n = 4),
        labels = scales::trans_format("log10", scales::math_format(10^.x))
    )
    x_log_ticks <- annotation_logticks(
        sides = "b", short = unit(0.03, "cm"),
        mid = unit(0.08, "cm"), long = unit(0.11, "cm")
    )
    y_log_ticks <- annotation_logticks(
        sides = "l", short = unit(0.03, "cm"),
        mid = unit(0.08, "cm"), long = unit(0.11, "cm")
    )
    x_norm <- scale_x_continuous(breaks = scales::pretty_breaks(n = 3))
    y_norm <- scale_y_continuous(breaks = scales::pretty_breaks(n = 3))
    for (col in 1:k) {
        for (row in col:k) {
            if (col %in% log_vars) {
                p[row, col] <- p[row, col] + x_log
                if (row == k) {
                    p[row, col] <- p[row, col] + x_log_ticks
                }
            } else {
                p[row, col] <- p[row, col] + x_norm
            }
            if (row %in% log_vars & row != col) {
                p[row, col] <- p[row, col] + y_log
                if (col == 1) {
                    p[row, col] <- p[row, col] + y_log_ticks
                }
            } else if (row != col) {
                p[row, col] <- p[row, col] + y_norm
            }
        }
    }
    p
}

tbl_corr <- tbl %>%
    filter(!is.na(nr_cliques), type == "real") %>%
    select(degeneracy, closure_weak, closure, het, loc, val)

## tbl_corr <- tbl[tbl$type == "real" & !tbl$timeout, ]
## tbl_corr <- tbl_corr[, c(
##     "degeneracy", "closure_weak", "closure",
##     "het", "loc", "val", "outlier", "timeout",
##     "type"
## )]
labels <- c(
    "degeneracy", "weak closure", "closure",
    "heterogeneity", "locality", "nr cliques / m"
)

p1 <- correllation_plot(tbl_corr %>% filter(val <= 1), labels,
    log_vars = c(1, 2, 3)
)
p2 <- correllation_plot(tbl_corr %>% filter(val > 1), labels,
    log_vars = c(1, 2, 3, 6), color_transform = log10
)

create_pdf("R/output/cliques_correlation.pdf", p1, height = 1)
create_pdf("R/output/cliques_correlation_outliers.pdf", p2, height = 1)


######################################################################
## weak closure vs. degeneracy
msg("degeneracy / (weak closure - 1) for outliers")
print(summary(tbl_high$degeneracy / (tbl_high$closure_weak - 1)))
msg("")

p <- ggplot(tbl_high, aes(x = degeneracy / (closure_weak - 1))) +
    geom_histogram(fill = blue, color = "black", bins = 30) +
    xlab("degeneracy / (weak closure - 1)")
create_pdf("R/output/degeneracy_vs_weak_closure.pdf",
    p,
    width = 0.45, height = 0.45
)


######################################################################
## weak closure vs. degeneracy depending on locality
tbl_comp <- tbl %>%
    mutate(
        degen_closure_diff = degeneracy / (closure_weak - 1),
        instance_type = case_when(
            is.na(val) ~ "timeout",
            val > 1 ~ "more than m cliques",
            val <= 1 ~ "at most m cliques"
        )
    ) %>%
    graph_filter(rm_square = TRUE)

p <- ggplot(
    tbl_comp,
    aes(x = loc, y = degen_closure_diff, color = instance_type)
) +
    geom_point(alpha = 0.6, size = 0.5) +
    scale_color_manual(values = c(green, yellow, red)) +
    scale_y_log10() +
    annotation_logticks(sides = "l") +
    xlab("locality") +
    ylab("degeneracy / (weak closure - 1)") +
    theme(
        legend.position = c(0, 1), legend.justification = c(0, 1),
        legend.title = element_blank(),
        legend.background = element_rect(fill = "transparent")
    )
create_pdf("R/output/degeneracy_vs_weak_closure_locality.pdf", p,
    width = 0.45, height = 0.45
)

cor(tbl_comp$loc, tbl_comp$degen_closure_diff, method = "spearman")
cor((tbl_comp %>% filter(val <= 1)) %>% pull(loc),
    tbl_comp %>% filter(val <= 1) %>% pull(degen_closure_diff),
    method = "spearman"
)
cor((tbl_comp %>% filter(val > 1)) %>% pull(loc),
    tbl_comp %>% filter(val > 1) %>% pull(degen_closure_diff),
    method = "spearman"
)
