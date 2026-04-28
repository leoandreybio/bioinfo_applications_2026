# Downloading RNAseq data from SRA

## Repository to store the data
mkdir -p data/rnaseq

## Downloading the data using fastq-dump
module load SRA-Toolkit
fastq-dump --split-files -O data/rnaseq SRR17844033


