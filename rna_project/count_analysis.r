library(tidyverse)

# ---- CONFIGURATION ----

# Set the path to the gene count file for your sample
# Add the path to your sample's gene count file here. 
sample_counts_file <- "conger/counts/SRR17844033_GCF_963514075.1_gene_counts.txt" # <-- Change this for your sample

# Set the output directory for the CSV file
# Add the path to the directory of your choice. I recommend putting it in the repository where your counts are located.
output_dir <- "." # <-- Change this to your desired output directory (e.g., "results/")

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
# Save the top 10 most expressed genes to a CSV file in the specified directory
output_file <- file.path(output_dir, "top10_most_expressed_genes.csv")
write_csv(top10_genes, output_file)
cat(paste0("Top 10 most expressed genes saved to ", output_file, "\n"))

