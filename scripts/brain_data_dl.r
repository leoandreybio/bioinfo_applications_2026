# ---------------
# Title: brain data download
# Date: 09.03.2026
# Author: Léo Andrey
# Goal: Download the brain and body mass data from FishBase
# ---------------

# libraries --------------------------------------------------------------------

#if (!dir.exists("~/R/x86_64-pc-linux-gnu-library/")) {
#  dir.create("~/R/x86_64-pc-linux-gnu-library/", recursive = TRUE)
#}
#remotes::install_github("jonchang/fishtree", lib = "~/R/x86_64-pc-linux-gnu-library/")
#remotes::install_github("ropensci/rfishbase", lib = "~/R/x86_64-pc-linux-gnu-library/")

library(fishtree) # fish phylogeny
library(rfishbase) # fish trait database
library(worrms) # fish taxonomy database
library(ape) # manipulation of phylogenetic trees
library(phytools) # manipulation and visualisation of phylogenetic data
library(geiger) # tools for evolution models and manipulation of trees
library(tidyverse) # dplyr and ggplot among others
library(Cairo)


######### télécharger les traits de la database
raw_brains <- rfishbase::fb_tbl("brains")
glimpse(raw_brains)
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
plot(log10(brains$brain_weight) ~ log10(brains$body_weight))
hist(brains$rel_brain_size)

spec_names <- rfishbase::species_names()

brains <- inner_join(spec_names, brains, join_by(SpecCode))
glimpse(brains)

####### étlécharger la phylogénie

# phylo object type :
# str(phy)
# phy$edge => tree structure
# phy$edge.length => length of the branches specified in phy$edge
# phy$tip.label => OTU (species) names
# plot(phy, "fan")
# plot(phy, "phylogram")
# plot(phy, "cladogram")
# phy2 <- drop.tip(phy, c(species_names)) => removes species
# phy3 <- keep.tip(phy, c(species_names)) => removes all but some species

phy <- fishtree::fishtree_phylogeny()
phy
windows()
par(mfrow = c(2, 1))
plot(phy, show.tip.label = FALSE)
ape::ltt.plot(phy)

###### les noms des espèces et pruning de la phylogénie
phy$tip.label <- gsub("_", " ", phy$tip.label)
phy$tip.label

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

fishbase_check_phy <- lapply(phy$tip.label, rfishbase::validate_names) # takes too much time


checked_names <- geiger::name.check(phy, data.names = brains$Species)
length(brains$Species)
length(checked_names$data_not_tree)

length(phy$tip.label)
brainphy <- ape::drop.tip(phy, checked_names$tree_not_data)
length(brainphy$tip.label)

brains <- filter(brains, Species %in% brainphy$tip.label)
brains <- brains[match(brainphy$tip.label, brains$Species), ]
length(brains$Species)

brainvector <- brains$rel_brain_size
names(brainvector) <- brains$Species

pdf(file = "contMap_plot.pdf", width = 35, height = 35) # Set dimensions
contMap(
  brainphy,
  brainvector,
  type = "fan",
  fsize = c(0.7, 1.1),
  outline = FALSE
)
dev.off() # Close the device
