#!/bin/bash
set -e

# Usage: ./script_rnaseq.sh <SRA_ACCESSION> <GENOME_ACCESSION>
# Example: ./script_rnaseq.sh SRR17844033 GCF_963514075.1

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <SRA_ACCESSION> <GENOME_ACCESSION>"
  exit 1
fi

SRA_ACC="$1"
GENOME_ACC="$2"

## Extract path for genome accession (e.g., GCF_053564925.1 -> 053/564/925)
GENOME_DIGITS=$(echo $GENOME_ACC | sed -E 's/^GCF_([0-9]+)\..*/\1/')
GENOME_PATH_PART=$(echo $GENOME_DIGITS | rev | sed -E 's/(.{3})/\1\//g' | rev | sed 's#/$##')
GENOME_DIR="data/genomes/$GENOME_ACC"

# Downloading RNAseq data from SRA
mkdir -p data/rnaseq
module load SRA-Toolkit
fastq-dump --split-files -O data/rnaseq $SRA_ACC

# Running FastQC for quality control
module load FastQC
mkdir -p reports/fastqc_report
fastqc -o reports/fastqc_report data/rnaseq/${SRA_ACC}_1.fastq
fastqc -o reports/fastqc_report data/rnaseq/${SRA_ACC}_2.fastq

# Trimming the reads using Trimmomatic
module load Trimmomatic
mkdir -p data/rnaseq/trimmed
trimmomatic PE -threads 4 -phred33 \
  data/rnaseq/${SRA_ACC}_1.fastq data/rnaseq/${SRA_ACC}_2.fastq \
  data/rnaseq/trimmed/${SRA_ACC}_1.paired.fastq data/rnaseq/trimmed/${SRA_ACC}_1.unpaired.fastq \
  data/rnaseq/trimmed/${SRA_ACC}_2.paired.fastq data/rnaseq/trimmed/${SRA_ACC}_2.unpaired.fastq \
  ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

# Downloading the reference genome
mkdir -p "$GENOME_DIR"
cd "$GENOME_DIR"
module load Anaconda3
if ! conda env list | grep -q NCBI-tools; then
  conda create -y -n NCBI-tools -c bioconda -c conda-forge ncbi-datasets-cli
fi
source $(conda info --base)/etc/profile.d/conda.sh
conda activate NCBI-tools

# Try datasets CLI, fallback to wget if needed
if ! datasets download genome accession $GENOME_ACC --include genome,gff3; then
  echo "datasets CLI failed, using wget fallback..."
  wget -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/$GENOME_PATH_PART/${GENOME_ACC}_genomic.fna.gz || true
  wget -c ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/$GENOME_PATH_PART/${GENOME_ACC}_genomic.gff.gz || true
else
  unzip -o ncbi_dataset.zip
fi

# Find the genome fasta file (decompressed if needed)
GENOME_FASTA=$(find "$GENOME_DIR" -name "*.fna" | head -n 1)
if [ -z "$GENOME_FASTA" ]; then
  GENOME_FASTA_GZ=$(find "$GENOME_DIR" -name "*.fna.gz" | head -n 1)
  if [ -n "$GENOME_FASTA_GZ" ]; then
    gunzip -k "$GENOME_FASTA_GZ"
    GENOME_FASTA="${GENOME_FASTA_GZ%.gz}"
  else
    echo "Genome FASTA not found!"
    exit 1
  fi
fi

cd -

# Aligning the reads to the reference genome using HISAT2
module load HISAT2
mkdir -p data/rnaseq/alignment

# Build index if not present
INDEX_DIR="$GENOME_DIR/index"
INDEX_BASENAME="$INDEX_DIR/conger_index"
if [ ! -f "$INDEX_BASENAME.1.ht2" ]; then
  mkdir -p "$INDEX_DIR"
  hisat2-build "$GENOME_FASTA" "$INDEX_BASENAME"
fi

# Align reads
hisat2 -x "$INDEX_BASENAME" \
  -1 data/rnaseq/trimmed/${SRA_ACC}_1.paired.fastq \
  -2 data/rnaseq/trimmed/${SRA_ACC}_2.paired.fastq \
  -S data/rnaseq/alignment/${SRA_ACC}_aligned.sam