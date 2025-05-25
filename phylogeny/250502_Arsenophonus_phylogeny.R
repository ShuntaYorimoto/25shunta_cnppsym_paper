#!/usr/bin/env Rscript

# Load required libraries
library(ggplot2)
library(ggtree)
library(treeio)

# Read tree file
tree <- read.tree("concatenated_MSAs_RMLNG.raxml.support")

# Reroot the tree
rerooted_tree <- root(tree, outgroup = "ProMi", edgelabel = TRUE)

# Load metadata
metadata <- read.delim("species_info.tsv", sep = "\t", 
                       header = TRUE, stringsAsFactors = FALSE)

# Format genome sizes with NA
metadata$gensize <- ifelse(
  !is.na(metadata$gensize),
  format(as.numeric(metadata$gensize), nsmall=2), NA)

# Plot the tree
p <- ggtree(rerooted_tree) %<+% metadata +
  # Add bootstrap values at the nodes (for values >= 70)
  geom_nodepoint(
    aes(subset = !is.na(as.numeric(label)) & as.numeric(label) >= 70,
        fill = case_when(
          as.numeric(label) == 100 ~ "green",
          as.numeric(label) >= 90 ~ "yellow",
          TRUE ~ "orange")),
    size=2, shape=21, color="black") +
  scale_fill_identity() +
  guides(fill="none") +
  # Add tip labels
  geom_tiplab(aes(label=species_symbiont),
              fontface="italic", size=3, align=TRUE) +
  # Add scale bar
  geom_treescale(x=0, y=0, fontsize=2.5, width=0.05, offset=0.2) +
  # Theme adjustments
  theme(text = element_text(family="Arial"),
        panel.background = element_blank(),
        plot.background = element_blank())

# Add metadata
p2 <- p +
  # Add species host names
  geom_text(aes(x=1.5, label=species_host), 
            hjust=0, size=3, fontface="italic", na.rm=TRUE) +
  # Add common host names
  geom_text(aes(x=2.0, label=name), hjust=0, size=3, na.rm=TRUE) +
  # Add genome sizes
  geom_text(aes(x=2.5, label=gensize), hjust=1, size=3, na.rm=TRUE) +
  xlim(0, 2.8)

# Display the plot
print(p2)

# Save the plot as an SVG file
ggsave("phylogenetic_tree_Ars.svg", p2, width = 172, height = 70,
       units = "mm", device = "svg", bg = "transparent")

