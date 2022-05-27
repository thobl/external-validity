## general theme
theme_set(theme_bw())

## latex font
font_add("LM Roman", "lmroman10-regular.otf")
showtext_auto()
theme_update(text = element_text(family = "LM Roman", size = 9))

## some colors
blue   <- "#5EA6E5"
green  <- "#6EC620"
yellow <- "#EEC200"
red    <- "#E62711"
violet <- "#c6468d"
purple <- "#613872"
gray   <- "#666666"

## pdf output; width and height relative to LIPIcs text width
create_pdf <- function(file, plot, width = 1, height = 0.43) {
    textwidth <- 14 / 2.54
    pdf(file, width = width * textwidth, height = height * textwidth)
    print(plot)
    no_output <- dev.off()
}
