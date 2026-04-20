# ---------------
# Title: brain data download
# Date: 09.03.2026
# Author: Léo Andrey
# Goal: Download the brain and body mass data from FishBase
# ---------------

# libraries --------------------------------------------------------------------

#remotes::install_github("jonchang/fishtree", lib = "~/R/x86_64-pc-linux-gnu-library/")
#remotes::install_github("ropensci/rfishbase", lib = "~/R/x86_64-pc-linux-gnu-library/")

library(fishtree) # fish phylogeny
library(rfishbase) # fish trait database
library(worrms) # fish taxonomy database
library(ape) # manipulation of phylogenetic trees
library(phytools) # manipulation and visualisation of phylogenetic data
library(geiger) # tools for evolution models and manipulation of trees
library(tidyverse) # dplyr and ggplot among others

# 1 Traits database ------------------------------------------------------------

# traits db download
raw_brains <- rfishbase::fb_tbl("brains")
glimpse(raw_brains)

# removing of NAs and calculation of brain residuals
brains <- raw_brains %>%
  filter(!is.na(BodyWeight), !is.na(BrainWeight), !is.na(SpecCode)) %>%
  group_by(SpecCode) %>%
  summarise(
    body_weight = mean(BodyWeight),
    brain_weight = mean(BrainWeight)
  ) %>%
  mutate(
    rel_brain_size = residuals(lm(log10(brain_weight) ~ log10(body_weight)))
  )
# residuals visualisation
plot(log10(brains$brain_weight) ~ log10(brains$body_weight))
hist(brains$rel_brain_size)

# add species names to the data
spec_names <- rfishbase::species_names()
brains <- inner_join(spec_names, brains, join_by(SpecCode))
glimpse(brains)

summary(brains)
smol <- filter(brains, rel_brain_size <= quantile(rel_brain_size, 0.05, na.rm = TRUE))

# 2 Phylogenetic tree ------------------------------------------------------------

# downloading a fish phylogeny
phy <- fishtree::fishtree_phylogeny()
str(phy)

# standardising species names
phy$tip.label <- gsub("_", " ", phy$tip.label)
phy$tip.label

# 3 Matching the db and the tree -------------------------------------------------

# matching name convention between traits db and tree
# method 1 with WORMS
checknames <- function(speclist) {
  correct_names_list <- c()

  for (i in speclist) {
    worms_query <- wm_records_name(i)

    if (!is.null(worms_query) && nrow(worms_query) > 0) {
      correct_name <- worms_query$valid_name[1]
    } else {
      correct_name <- NA
    }

    correct_names_list <- append(correct_names_list, correct_name)
  }

  return(correct_names_list)
}
worms_check_phy <- checknames(phy$tip.label) # does not contain freshwater species
worms_check_fb <- checknames(spec_names)

# method 2 with FishBase
fishbase_check_phy <- lapply(phy$tip.label, rfishbase::validate_names) # takes too much time

# pruning the tree to the database species
# checking which species names are too much in the tree
checked_names <- geiger::name.check(phy, data.names = brains$Species)
length(brains$Species)
length(checked_names$data_not_tree)

# removing those tips and associated nodes
length(phy$tip.label)
brainphy <- ape::drop.tip(phy, checked_names$tree_not_data)
length(brainphy$tip.label)

# ordering the db to the order of the tree
brains <- filter(brains, Species %in% brainphy$tip.label)
brains <- brains[match(brainphy$tip.label, brains$Species), ]
length(brains$Species)

# 4 Visualise the trait onto the phylogeny ----------------------------------------

# create a vector with the brain size ans species names
brainvector <- brains$rel_brain_size
names(brainvector) <- brains$Species

# save the contmap graph in a PDF
pdf(file = "contMap_plot.pdf", width = 35, height = 35) # set dimensions
contMap(
  brainphy,
  brainvector,
  type = "fan",
  fsize = c(0.7, 1.1),
  outline = FALSE
)
dev.off()
