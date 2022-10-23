main_plot <- function(tbl,
                      val_title = "value",
                      val_colors = c(green, yellow, red),
                      val_color_trans = "identity",
                      point_size_scale = 1,
                      aggr_nr_bins = 10,
                      aggr_fun = mean,
                      val_limits = NULL,
                      no_legend = FALSE) {
    ## textual description for plotly (html)
    tbl <- tbl %>% mutate(text = sprintf(
        "graph: %s\nhet: %.3f\nloc: %.3f\nval: %.3f",
        graph, het, loc, val
    ))

    ## use color limits if given
    if (is.null(val_limits)) {
        val_limits <- c(min(tbl$val), max(tbl$val))
    }

    ## plot elements common to all three plots
    common <- list(
        scale_colour_gradientn(
            name = paste0(val_title, "\n "),
            limits = val_limits,
            colors = val_colors,
            trans = val_color_trans
        ),
        xlim(c(min(tbl$het), max(tbl$het))),
        ylim(c(min(tbl$loc), max(tbl$loc))),
        xlab("heterogeneity"),
        ylab("locality")
    )

    ## non-aggregated plots
    plot_non_aggregated <- function(tbl, alpha = 0.5) {
        ## the plot
        ggplot(tbl, aes(x = het, y = loc, color = val, text = text)) +
            geom_point(alpha = alpha, size = point_size_scale * 0.8, shape = 16) +
            facet_grid(
                cols = vars(type),
                labeller = labeller(
                    type = c(
                        generated = "Generated Networks",
                        real = "Real-World Networks"
                    )
                )
            ) +
            common
    }


    ## plot for generated networks (non-aggregated)
    p1 <- plot_non_aggregated(tbl %>% filter(type == "generated"), alpha = 1.0)


    ## only return p1 if there is no real-world data
    if (tbl %>% filter(type == "real") %>% nrow() == 0) {
        return(p1)
    }

    ## plot for real-world networks (non-aggregated)
    p2 <- plot_non_aggregated(tbl %>% filter(type == "real"))

    ## plot for real-world networks (aggregated)
    p3 <- ggplot(
        tbl %>% filter(type == "real"),
        aes(x = het, y = loc, z = val)
    ) +
        stat_aggregate_2d(aes(text = stat(text)),
            fun = aggr_fun, bins = aggr_nr_bins
        ) +
        facet_grid(
            cols = vars(type),
            labeller = labeller(
                type = c(real = "Real-World (Aggregated)")
            )
        ) +
        scale_radius(
            name = "nr. of\nnetworks",
            range = point_size_scale * c(0.14, 4.2),
            trans = "log10"
        ) +
        guides(
            color = guide_colorbar(order = 1, direction = "horizontal"),
            size = guide_legend(order = 2, direction = "horizontal")
        ) +
        theme(legend.position = "top") +
        common

    ## elements for removing labels and y-axis
    noy <- theme(
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.y = element_blank()
    )

    ## legend theme for the aggregated plot
    leg_theme <- theme(
        legend.justification = c(1, 1),
        legend.key.height = unit(0.35, "cm"),
        legend.margin = margin(t = 0, r = 0, b = -0.2, l = 0, unit = "cm"),
        legend.spacing = unit(1.8, "cm")
    )
    if (no_legend) {
        leg_theme <- theme(legend.position = "none")
    }

    ## arranging the plots
    p <- ggarrange(p1 + rremove("xlab") + theme(legend.position = "none"),
        p2 + rremove("ylab") + noy + theme(legend.position = "none"),
        p3 + rremove("xlab") + rremove("ylab") + noy + leg_theme,
        nrow = 1
    )

    ## returning p and p1 - p3
    list(p = p, p1 = p1, p2 = p2, p3 = p3)
}


girg_plot <- function(tbl,
                      val_title = "value",
                      val_colors = c(green, yellow, red),
                      val_color_trans = "identity",
                      point_size_scale = 1,
                      val_limits = NULL,
                      no_legend = FALSE) {
    ## reduce table to girgs and figure out type (torus/square)
    tbl <- tbl %>%
        filter(type_detailed == "girg") %>%
        mutate(type = ifelse(gen_square, "square", "torus"))

    ## use color limits if given
    if (is.null(val_limits)) {
        val_limits <- c(min(tbl$val), max(tbl$val))
    }

    ## legend theme
    leg_theme <- theme(
        legend.position = "top",
        legend.justification = c(0.5, 1),
        legend.key.height = unit(0.35, "cm"),
        legend.margin = margin(t = 0, r = 0, b = -0.2, l = 0, unit = "cm"),
        legend.spacing = unit(1.8, "cm")
    )
    if (no_legend) {
        leg_theme <- theme(legend.position = "none")
    }

    ## actual plot
    ggplot(tbl, aes(x = het, y = loc, color = val)) +
        geom_point(alpha = 1, size = point_size_scale * 0.8) +
        facet_grid(
            cols = vars(type),
            labeller = labeller(
                type = c(
                    torus = "GIRGs with Torus",
                    square = "GIRGs with Square"
                )
            )
        ) +
        scale_colour_gradientn(
            name = paste0(val_title, "\n "),
            limits = val_limits,
            colors = val_colors,
            trans = val_color_trans
        ) +
        xlim(c(min(tbl$het), max(tbl$het))) +
        ylim(c(min(tbl$loc), max(tbl$loc))) +
        xlab("heterogeneity") +
        ylab("locality") +
        leg_theme
}


mid_plot_with_extreme <- function(tbl,
                                  val_title = "value",
                                  val_colors = c(green, yellow, red),
                                  val_color_trans = "identity",
                                  point_size_scale = 1,
                                  val_limits = NULL) {
    ## textual description for plotly (html)
    tbl <- tbl %>% mutate(text = sprintf(
        "graph: %s\nhet: %.3f\nloc: %.3f\nval: %.3f",
        graph, het, loc, val
    ))

    ## use color limits if given
    if (is.null(val_limits)) {
        val_limits <- c(min(tbl$val), max(tbl$val))
    }

    p <- ggplot(
        tbl %>% filter(type == "real"),
        aes(
            x = het, y = loc, color = val, text = text,
            shape = (het < het_extreme_min | het > het_extreme_max)
        )
    ) +
        geom_vline(xintercept = het_extreme_min, size = 0.15) +
        geom_vline(xintercept = het_extreme_max, size = 0.15) +
        geom_point(alpha = 0.5, size = point_size_scale * 0.8) +
        xlim(c(min(tbl$het), max(tbl$het))) +
        ylim(c(min(tbl$loc), max(tbl$loc))) +
        xlab("heterogeneity") +
        ylab("locality") +
        scale_colour_gradientn(
            name = val_title,
            limits = val_limits,
            colors = val_colors,
            trans = val_color_trans
        ) +
        scale_shape(guide = "none") +
        theme(
            legend.key.height = unit(0.35, "cm"),
            legend.margin = margin(t = 0, r = 0, b = -0.2, l = 0, unit = "cm"),
            legend.position = "top"
        ) +
        guides(color = guide_colourbar(
            title.position = "top",
            title.hjust = 0.5
        ))

    p
}
