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

# Trimming the reads using Trimmomatic

# Loading the module
module load Trimmomatic

# Repository to store the trimmed reads
mkdir -p data/rnaseq/trimmed

# Running Trimmomatic on both files
trimmomatic PE -threads 4 -phred33 \
data/rnaseq/SRR17844033_1.fastq data/rnaseq/SRR17844033_2.fastq \
data/rnaseq/trimmed/SRR17844033_1.paired.fastq data/rnaseq/trimmed/SRR17844033_1.unpaired.fastq \
data/rnaseq/trimmed/SRR17844033_2.paired.fastq data/rnaseq/trimmed/SRR17844033_2.unpaired.fastq \
ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36