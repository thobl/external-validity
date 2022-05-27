
sanitize_number <- function(accuracy) {
    function(num) {
        paste0("\\num{", scales::number(num, accuracy = accuracy, big.mark = ""), "}")
    }
}

sanitize_percent <- function(accuracy) {
    function(num) {
        paste0("\\SI{", scales::number(num * 100, accuracy = accuracy, big.mark = ""), "}{\\%}")
    }
}

sanitize_text <- xtable::sanitize

sanitize_table <- function(tbl, functions) {
    for (i in seq_len(ncol(tbl))) {
        tbl[, i] <- functions[[i]](tbl[, i])
    }
    return(tbl)
}
