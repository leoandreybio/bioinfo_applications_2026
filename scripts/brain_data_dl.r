# ---------------
# Title: brain data download
# Date: 09.03.2026
# Author: Léo Andrey
# Goal: Download the brain and body mass data from FishBase
# ---------------

# libraries --------------------------------------------------------------------

if (!dir.exists("~/R/x86_64-pc-linux-gnu-library/")) {
  dir.create("~/R/x86_64-pc-linux-gnu-library/", recursive = TRUE)
}

remotes::install_github("jonchang/fishtree", lib = "~/R/x86_64-pc-linux-gnu-library/")
remotes::install_github("ropensci/rfishbase", lib = "~/R/x86_64-pc-linux-gnu-library/")

library(fishtree)
library(rfishbase)

miam <- rfishbase::fb_tbl("BrainBody")

