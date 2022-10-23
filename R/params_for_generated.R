source("R/helper/load_helpers.R")

######################################################################
## read the data
tbl_base <- read_basic() %>%
    filter(type == "generated") %>%
    graph_filter(rm_deg_20 = TRUE)
tbl <- tbl_base %>%
    graph_filter(rm_square = TRUE) %>%
    aggregate_generated() %>%
    arrange(gen_ple, gen_T)


######################################################################
## plotting parameter grid
tbl_girg <- tbl %>% filter(type_detailed == "girg")
tbl_cl_er <- tbl %>% filter(type_detailed != "girg")
p <- ggplot(tbl, aes(x = het, y = loc, color = type_detailed)) +
    geom_path(data = tbl_girg, aes(group = gen_T)) +
    geom_path(data = tbl_girg, aes(group = gen_ple)) +
    geom_text(
        data = tbl_girg[tbl_girg$gen_T == 0, ],
        aes(label = paste("β =", gen_ple)),
        size = 3,
        angle = 45, hjust = 0, nudge_y = 0.03, show.legend = FALSE
    ) +
    geom_text(
        data = tbl_girg[tbl_girg$gen_ple == 25, ],
        aes(label = paste("T =", gen_T)),
        size = 3,
        nudge_x = -0.07, hjust = "outward", show.legend = FALSE
    ) +
    geom_path(data = tbl_cl_er) +
    geom_text(
        data = tbl_cl_er[tbl_cl_er$type_detailed == "cl", ],
        aes(
            label = paste("β =", gen_ple),
            angle = 0 - 45 * (gen_ple > 3),
            hjust = 0 - 0.2 * (gen_ple <= 3)
        ),
        size = 3,
        nudge_y = -0.02, show.legend = FALSE
    ) +
    geom_point() +
    xlim(-1.00, 1.27) +
    ylim(-0.08, 0.98) +
    xlab("heterogeneity") +
    ylab("locality") +
    scale_color_manual(
        name = "Network Model",
        labels = c(girg = "GIRG", er = "Erdős–Rényi", cl = "Chung–Lu"),
        values = c(girg = green, er = red, cl = blue)
    )
create_pdf("R/output/params_of_generated_networks.pdf", p, height = 0.79)



######################################################################
## helper stuff for estimating the parameters to get uniform
## heterogeneity / locality

tbl_T <- tbl %>% filter(type_detailed == "girg", gen_T == 0.7)
f <- approxfun(tbl_T$het, tbl_T$gen_ple)
f(0)
p <- ggplot(
    tbl_T,
    aes(x = gen_ple, y = het, color = gen_T, group = gen_T)
) +
    geom_point() +
    geom_line() +
    scale_x_log10()
min_het <- min(tbl_T$het)
max_het <- max(tbl_T$het)
values <- 0:9 / 9 * (max_het - min_het) + min_het
values <- pmin(values, max_het)
for (i in values) {
    p <- p +
        geom_hline(yintercept = i) +
        geom_vline(xintercept = f(i))
}
p
values
f(values)

tbl_ple <- tbl %>% filter(type_detailed == "girg", gen_ple == 3.0)
f <- approxfun(tbl_ple$loc, tbl_ple$gen_T)
p <- ggplot(
    tbl_ple,
    aes(x = gen_T, y = loc, color = log10(gen_ple), group = gen_ple)
) +
    geom_point() +
    geom_line()
min_loc <- min(tbl_ple$loc)
max_loc <- max(tbl_ple$loc)
values <- 0:9 / 9 * (max_loc - min_loc) + min_loc
values <- pmin(values, max_loc)
for (i in values) {
    p <- p + geom_hline(yintercept = i) + geom_vline(xintercept = f(i))
}
p
values
f(values)

######################################################################
## some additional stats
tbl_girg <- tbl_base %>%
    graph_filter(rm_square = TRUE) %>%
    filter(type_detailed == "girg")
tbl_girg_square <- tbl_base %>%
    graph_filter(rm_torus = TRUE) %>%
    filter(type_detailed == "girg")
tbl_cl <- tbl_base %>% filter(type_detailed == "cl")
tbl_er <- tbl_base %>% filter(type_detailed == "er")

msg(sprintf(
    "n ranges from %d to %d with mean %f for GIRGs",
    min(tbl_girg$n), max(tbl_girg$n), mean(tbl_girg$n)
))
msg(sprintf(
    "n ranges from %d to %d with mean %f for square GIRGs",
    min(tbl_girg_square$n), max(tbl_girg_square$n), mean(tbl_girg_square$n)
))
msg(sprintf(
    "n ranges from %d to %d with mean %f for CLs",
    min(tbl_cl$n), max(tbl_cl$n), mean(tbl_cl$n)
))
msg(sprintf(
    "n ranges from %d to %d with mean %f for ERs",
    min(tbl_er$n), max(tbl_er$n), mean(tbl_er$n)
))
msg("")

msg(sprintf(
    "avg deg ranges from %f to %f with mean %f for GIRGs",
    min(tbl_girg$avg_deg), max(tbl_girg$avg_deg), mean(tbl_girg$avg_deg)
))
msg(sprintf(
    "avg deg ranges from %f to %f with mean %f for square GIRGs",
    min(tbl_girg_square$avg_deg), max(tbl_girg_square$avg_deg),
    mean(tbl_girg_square$avg_deg)
))
msg(sprintf(
    "avg deg ranges from %f to %f with mean %f for CLs",
    min(tbl_cl$avg_deg), max(tbl_cl$avg_deg), mean(tbl_cl$avg_deg)
))
msg(sprintf(
    "avg deg ranges from %f to %f with mean %f for ERs",
    min(tbl_er$avg_deg), max(tbl_er$avg_deg), mean(tbl_er$avg_deg)
))
msg("")
