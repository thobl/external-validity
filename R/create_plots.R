options(warn = -1)
options(dplyr.summarise.inform = FALSE)
pdf(NULL)
source("R/helper/load_helpers.R")

msg("######################################################################")
msg("Creating BFS Plots")
msg("")
source("R/bbbfs.R")


msg("")
msg("######################################################################")
msg("Creating Clique Plots")
msg("")
source("R/cliques.R")


msg("")
msg("######################################################################")
msg("Creating Chromatic Number Plots")
msg("")
source("R/coloring.R")


msg("")
msg("######################################################################")
msg("Creating Diameter Plots")
msg("")
source("R/diameter.R")


msg("")
msg("######################################################################")
msg("Creating Louvain Plots")
msg("")
source("R/louvain.R")


msg("")
msg("######################################################################")
msg("Creating Vertex Cover Plots")
msg("")
source("R/vertex_cover_dominance.R")


msg("")
msg("######################################################################")
msg("Additional Plots/Tables for Locality and Heterogeneity")
msg("(real-world)")
msg("")
source("R/locality_heterogeneity_measures.R")


msg("")
msg("######################################################################")
msg("Additional Plots/Tables for Locality and Heterogeneity")
msg("(generated)")
msg("")
source("R/params_for_generated.R")


msg("")
msg("######################################################################")
msg("Additional Plots/Tables for Average Distance Computation")
msg("")
source("R/avg_dist_tests.R")


msg("")
msg("######################################################################")
msg("Export Data to CSV")
msg("")
source("R/data_export.R")
