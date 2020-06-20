p <- function(..., sep='') {
  paste(..., sep = sep)
}

library("ggplot2")

files = list.files("./results/02_param")
param = tools::file_path_sans_ext(files)


param <- data.frame( do.call(rbind, strsplit(param, '_')))
names(param) <- c("M", "m", "n", "r")

loci <- c()

for (f in files) {
  dat = read.csv(p("./results/02_param/", f), header = FALSE, skip = 5, sep = "\t", stringsAsFactors = FALSE)
  loci <- c(loci, dat$V5)
}

out <- param

out$loci <- loci
out$M <- as.integer(as.character(out$M))
out$m <- as.integer(as.character(out$m))
out$n <- as.integer(as.character(out$n))
out$r <- as.numeric(as.character(out$r))


out$n <- out$n - out$M

out$fac <- p(as.character(out$m), "_", as.character(out$n), "_", as.character(out$r))

maxy <- ceiling(max(out$loci)/500)*500
miny <- floor(min(out$loci)/500)*500

p <- ggplot(data = out, aes(x = M, y = loci, factor = fac, color = factor(n))) +
  theme_bw() +
#  scale_y_continuous(expand = c(0,0), limits = c(miny, maxy)) +
  geom_line(linetype = 2, size = 0.35) +
  geom_point(aes(shape = factor(m))) +
  facet_wrap(~r, scales = "free_y", ncol = 2)

ggsave(filename = "./results/param.png",
       plot = p,
       width = 6.5,
       height = 9,
       units = "in",
       dpi = 600)

ggsave(filename = "./results/param.pdf",
       plot = p,
       width = 6.5,
       height = 9,
       units = "in",
       dpi = 600)
