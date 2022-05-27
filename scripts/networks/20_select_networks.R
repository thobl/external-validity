tbl <- read.csv("scripts/networks/data/all_networks.csv")

tbl <- tbl[
    !is.na(tbl$clustering_avg_local) &
    !is.na(tbl$deg_max) &
    !is.na(tbl$deg_avg) &
    tbl$deg_avg < tbl$deg_max &
    tbl$deg_avg > 1 &
    tbl$m < 1e+6 &
    tbl$n > 30
   , ]

write.table(tbl$name, file = "scripts/networks/data/selected_networks.txt",
            row.names = FALSE, col.names = FALSE)
