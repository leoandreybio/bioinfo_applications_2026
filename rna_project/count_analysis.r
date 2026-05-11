library(tidyverse)

counts <- read_delim("rna_project/counts/conger_gene_counts.txt", delim = "\t", comment = "#")



counts <- counts %>% rename("count" = `data/rnaseq/alignment/conger_aligned_sorted.bam`)

# Order by count descending
counts <- counts %>% arrange(desc(count))
glimpse(counts)

