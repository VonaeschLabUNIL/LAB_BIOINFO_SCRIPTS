#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name coverm
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 50G
#SBATCH --time 02:00:00
#SBATCH --array=1-XXX

# Optional: script to compute the abundance of the MAGs in the samples using coverM

# Module - adpat
module load gcc/12.3.0
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/CoverM/coverm

# Variables
genome_dir=/scratch/<USERS>/<Project_scratch>/mags_output/MAGs
reads_dir=/scratch/<USERS>/<Project_scratch>/Cleaned_reads
outdir=/scratch/<USERS>/<Project_scratch>/mags_output/coverm/coverm_out
TMPDIR=/scratch/<USERS>/<Project_scratch>/mags_output/coverm/tmp

## Array variables
cd ${reads_dir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

mkdir -p ${outdir}/${sample_name}

# trimmed_mean: compute the average coverage of each position in the genome, average number of aligned reads overlapping each position after removing the most deeply and shallow-ly covered position
coverm genome --coupled ${reads_dir}/${sample_name}/${sample_name}_FASTP_BOWTIE2_R1_001.fastq.gz \
    ${reads_dir}/${sample_name}/${sample_name}_FASTP_BOWTIE2_R2_001.fastq.gz \
    --genome-fasta-directory ${genome_dir}/${sample_name} \
    -x fa \
    -m trimmed_mean \
    -p bwa-mem \
    -t 16 \
    -o ${outdir}/${sample_name}/${sample_name}_CoverM_trimmedMean.tsv

# covered_fraction to calculate the fraction of the genome covered by mapped reads. Using min-covered-fraction 0 includes low coverage.
coverm genome --coupled ${reads_dir}/${sample_name}/${sample_name}_FASTP_BOWTIE2_R1_001.fastq.gz \
    ${reads_dir}/${sample_name}/${sample_name}_FASTP_BOWTIE2_R2_001.fastq.gz \
    --genome-fasta-directory ${genome_dir}/${sample_name} \
    -x fa \
    -m covered_fraction \
    --min-covered-fraction 0 \
    -p bwa-mem \
    -t 16 \
    -o ${outdir}/${sample_name}/${sample_name}_CoverM_coverfract.tsv

# count to count the number of reads that align to each genome. It provides an absolute count of mapped reads for each genomic region. Useful for determining the abundance of specific genomes or region based on the number of reads that map to them. 
coverm genome --coupled ${reads_dir}/${sample_name}/${sample_name}_FASTP_BOWTIE2_R1_001.fastq.gz \
     ${reads_dir}/${sample_name}/${sample_name}_FASTP_BOWTIE2_R2_001.fastq.gz \
     --genome-fasta-directory ${genome_dir}/${sample_name} \
     -x fa \
     -m count \
     --min-covered-fraction 0 \
     -t 16 \
     -o ${outdir}/${sample_name}/${sample_name}_CoverM_count.tsv
