# Downloading RNAseq data from SRA

## Repository to store the data
mkdir -p data/rnaseq

## Downloading the data using fastq-dump
module load SRA-Toolkit
fastq-dump --split-files -O data/rnaseq SRR17844033

# Running FastQC for quality control

## Loading the module
module load FastQC

## Repository to store the reports
mkdir -p reports/fastqc_report

## Running fastqc on both files
fastqc -o reports/fastqc_report data/rnaseq/SRR17844033_1.fastq
fastqc -o reports/fastqc_report data/rnaseq/SRR17844033_2.fastq

# Trimming the reads using Trimmomatic

## Loading the module
module load Trimmomatic

## Repository to store the trimmed reads
mkdir -p data/rnaseq/trimmed

## Running Trimmomatic on both files
trimmomatic PE -threads 4 -phred33 \
data/rnaseq/SRR17844033_1.fastq data/rnaseq/SRR17844033_2.fastq \
data/rnaseq/trimmed/SRR17844033_1.paired.fastq data/rnaseq/trimmed/SRR17844033_1.unpaired.fastq \
data/rnaseq/trimmed/SRR17844033_2.paired.fastq data/rnaseq/trimmed/SRR17844033_2.unpaired.fastq \
ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# Downloading the reference genome

## Repository to store the reference genome
mkdir -p data/genomes/conger_conger

## Loading NCBI Datasets command-line tool
module load Anaconda3
conda create -n NCBI-tools -c bioconda -c conda-forge ncbi-datasets-cli
conda init
conda activate NCBI-tools

## Downloading the reference genome using datasets command-line tool
cd data/genomes/conger_conger
datasets download genome accession GCF_963514075.1 --include genome,gff3
unzip ncbi_dataset.zip

# Aligning the reads to the reference genome using HISAT2

## Loading the module
module load HISAT2

## Repository to store the alignment files
mkdir -p data/rnaseq/alignment

## Building the index for the reference genome
hisat2-build data/genomes/conger_conger/ncbi_dataset/data/GCF_963514075.1/GCF_963514075.1_fConCon1.1_genomic.fna data/genomes/conger_conger/ncbi_dataset/data/GCF_963514075.1/index/conger_index

## Aligning the reads to the reference genome
hisat2 -p 16 -x data/genomes/conger_conger/ncbi_dataset/data/GCF_963514075.1/index/conger_index \
	-1 data/rnaseq/trimmed/SRR17844033_1.paired.fastq \
	-2 data/rnaseq/trimmed/SRR17844033_2.paired.fastq \
	| samtools view -bS - > data/rnaseq/alignment/conger_aligned.bam