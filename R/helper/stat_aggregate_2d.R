parse_interval <- function(cut_label, fun = mean) {
    fun(as.numeric(unlist(strsplit(
        gsub("\\(|\\)|\\[|\\]", "", as.character(cut_label)), ","))))
}

interval_midpoint <- function(cut_label) {
    parse_interval(cut_label, fun = mean)
}

interval_min <- function(cut_label) {
    parse_interval(cut_label, fun = min)
}

interval_max <- function(cut_label) {
    parse_interval(cut_label, fun = max)
}

summary_label <- function(x) {
    sprintf("points: %s\nmedian: %.3f\nmean: %.3f",
            length(x), median(x), mean(x))
}

StatAggregate2d <- ggproto(
    "StatAggregate2d", Stat,
    compute_group = function(data, scales, bins = 10, fun = mean) {
        ## put into bins
        data$x_bucket <- cut(data$x, breaks = bins)
        data$y_bucket <- cut(data$y, breaks = bins)

        ## get bin boudnaries
        data$xmin <- sapply(data$x_bucket, interval_min)
        data$xmax <- sapply(data$x_bucket, interval_max)
        data$ymin <- sapply(data$y_bucket, interval_min)
        data$ymax <- sapply(data$y_bucket, interval_max)

        ## aggregate each bin
        data <- do.call(
            data.frame,
            aggregate(z ~ xmin + xmax + ymin + ymax, data,
                      FUN = function(x)
                          c(value = fun(x),
                            count = length(x),
                            text = summary_label(x))))

        ## rename and add some columns
        names(data) <- c("xmin", "xmax", "ymin", "ymax", "value", "count", "text")
        data$value <- as.numeric(data$value)
        data$count <- as.numeric(data$count)
        data$x <- (data$xmin + data$xmax) / 2
        data$y <- (data$ymin + data$ymax) / 2

        data
    },
    required_aes = c("x", "y", "z"),
    default_aes = aes(color = stat(value), size = stat(count))
)

stat_aggregate_2d <- function(mapping = NULL, data = NULL, geom = "point",
                              position = "identity", na.rm = FALSE, show.legend = NA,
                              inherit.aes = TRUE, ...) {
    layer(
        stat = StatAggregate2d, data = data, mapping = mapping, geom = geom,
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, ...)
    )
}
