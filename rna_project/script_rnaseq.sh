# Downloading RNAseq data from SRA

## Repository to store the data
mkdir -p data/rnaseq

## Downloading the data using fastq-dump
module load SRA-Toolkit
fastq-dump --split-files -O data/rnaseq SRR17844033

# Running FastQC for quality control

# Loading the module
module load FastQC

# Repository to store the reports
mkdir -p reports/fastqc_report

# Running fastqc on both files
fastqc -o reports/fastqc_report data/rnaseq/SRR17844033_1.fastq
fastqc -o reports/fastqc_report data/rnaseq/SRR17844033_2.fastq