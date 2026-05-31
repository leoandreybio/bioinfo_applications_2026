library(tidyverse)

# ---- CONFIGURATION ----
# Set the path to the gene count file for your sample
# Add the path to your sample's gene count file here. 
sample_counts_file <- "conger/counts/SRR17844033_GCF_963514075.1_gene_counts.txt" # <-- Change this for your sample
# -----------------------

# Read the counts file
counts <- read_delim(sample_counts_file, delim = "\t", comment = "#")

# Automatically detect the count column (should be the BAM file column)
count_col <- setdiff(colnames(counts), c("Geneid", "Chr", "Start", "End", "Strand", "Length"))[1]
counts <- counts %>% rename(count = all_of(count_col))

# Order by count descending
counts <- counts %>% arrange(desc(count))
glimpse(counts)
# Output the 10 most expressed genes
top10_genes <- head(counts, 10)
print("Top 10 most expressed genes:")
print(top10_genes)

