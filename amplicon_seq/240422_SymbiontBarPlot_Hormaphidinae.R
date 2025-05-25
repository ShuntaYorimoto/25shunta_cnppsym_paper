## Load library
library(tidyverse)
library(extrafont) # for Arial font
library(scales) # for scale %

## Load data
dat <- readxl::read_xlsx("Hormaphidinae_16S_summary.xlsx", sheet="Summary")
dat_tidy <- gather(dat, key="Symbiont", value="Count", 
                   Buchnera, Arsenophonus, Pectobacterium, Gilliamella,
                   Hemipteriphilus, Rickettsia, Others)

## Check Brewer Color
library(RColorBrewer)
display.brewer.all()
brewer.pal(9, "Set1")
brewer.pal(12, "Paired")
brewer.pal(12, "Set3")


## Draw 16S amplicon analysis barchart
dat_tidy <- dat_tidy %>%
  group_by(SampleID) %>%
  mutate(pct = Count / sum(Count))

host_sorted <- c("Cjap-Okazaki-2ndHost", "Cjap-Okazaki-gall",
                 "Ccer-Nagano-2ndHost1", "Ccer-Nagano-2ndHost2", "Ccer-Nagano-2ndHost3",
                 "Cnek-Okazaki-2ndHost",
                 "Cnek-Okazaki-gall1", "Cnek-Okazaki-gall2", "Cnek-Okazaki-gall3", "Cnek-Okazaki-gall4",
                 "Cnek-AIST-gall", "Cnek-YamagataSuiden-gall", "Cnek-YamagataKeio-gall",
                 "CspB-Okutama", "Pbam-Miyazaki", "Ppan-Okutama", 
                 "Ppan-Nagasaki1", "Ppan-Nagasaki2", "Ppan-Nagasaki3",
                 "Hbet-Masutomi-onsen", "Nyan-Okazaki")

symbiont_sorted <- rev(c("Buchnera", "Arsenophonus", "Pectobacterium", "Gilliamella",
                         "Hemipteriphilus", "Rickettsia","Others"))

bar_colors <- rev(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", 
                    "#FF7F00", "#A65628", "#999999"))

p <- ggplot(data = dat_tidy,
       mapping = aes(x = factor(SampleID, levels = host_sorted), y = pct, 
                     fill = factor(Symbiont, levels = symbiont_sorted))) +
  geom_bar(stat = "identity", position = "fill") +
  scale_fill_manual(values = bar_colors) +
  scale_x_discrete(limits = rev) +
  scale_y_continuous(labels = scales::percent, expand = c(0, 0), limits = c(0, 1)) + # truncate space from plot
  labs(x = NULL, y = "Relative abundance",
       fill = "") +
  guides(fill = guide_legend(reverse = TRUE)) +
  theme_minimal(base_family = "Arial", base_line_size = 0.5) +
  theme(legend.position = "bottom",
        legend.key.size = unit(8, "points"),
        legend.text = element_text(size = 8),
        strip.text = element_text(size = 8, face = "bold"),
        axis.title.x = element_text(size = 8),
        axis.text.x = element_text(size = 6),
        axis.text.y = element_text(size = 8),
        panel.spacing.x = unit(20, "points"), # separate two plots
        plot.margin = margin(0, 5, 0, 5, unit = "mm")) + # make margin for whole plot
  coord_flip()

p

ggsave(filename = "Cjap_Hormaphidinae.pdf",
       plot = p, device = cairo_pdf,
       width = 134, height = 100, units = "mm", dpi = 600)
