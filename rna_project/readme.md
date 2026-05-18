# RNAseq data processing pipeline

This repository contains a bash script and an R script. They semi-automatically perform the analysis of of RNAseq data, outputing the 10 most expressed gene in a given RNAseq run.

## BASH script - from raw data to counts

> This pipeline is in part adapted from Shouib et al. 2025. *bio-protocol*.

This pipeline automatises :

1. Downloading raw RNAseq data from the SRA database of NCBI, as well as the necessary genome and annotations.
2. Performing a quality check of the raw reads with FastQC, and trimming potential adapters using Trimmomatic.
3. Aligning the reads onto the genome, and converting it into a BAM file.
4. Couting the number of reads with the featureCounts tool from subread.

### Procedure

To run this part of the pipeline, create a new subdirectory and move into it.

> `mkdir new_folder`  
> `cd new_folder`

Then find the accession number of the RNAseq run of your choice on SRA (format: SRRXXXXXXXX), as well as the accesion number of an assembled genome of the corresponding species on NCBI (format: GCFXXXXXXXXX.1).  
**Make sure the genome contains also annotation files GTF/GFF**  

Finally, run the script in the folder you're in, and you should expect to have results in a few dozens of minutes

> `bash ../pipeline_rnaseq.sh SRRXXXXXXXX GCFXXXXXXXXX.1`

The script creates 3 subdirectories :
1. *reports* contains the FastQC reports on the raw reads.
2. *data* contains the genome, annotations, the raw and trimmed reads, and the alignment.
3. *counts* contains a .txt file with the counts.

## R script - counts analysis

This script outputs the 10 most expressed genes in the counts produced by the bash script.

### Procedure

To run this part of the pipeline, you must update the path to your counts file in the R script. You must also specify an output folder where you want the table containing the 10 most expressed genes to be created.  
Once this is done, you can simply run the script and look at the results.

## Trimmomatic settings

Trimmomatic uses information contained in the *TruSeq3-PE.fa* file to make the trimming. If the trimming is not working properly, you might need to replace this file with the sequence of other adapters. Find information here: https://github.com/usadellab/Trimmomatic/tree/main/adapters.