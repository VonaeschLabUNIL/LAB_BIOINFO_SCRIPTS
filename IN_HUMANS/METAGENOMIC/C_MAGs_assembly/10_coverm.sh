#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name coverm
#SBATCH --output /scratch/syersin2/Satellite_scratch/mags_output/coverm/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Satellite_scratch/mags_output/coverm/std_output/%x_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user simon.yersin@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 50G
#SBATCH --time 02:00:00
#SBATCH --array=1

# Module
module load gcc/12.3.0
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/CoverM/coverm

# Variables
genome_dir=/scratch/syersin2/Satellite_scratch/mags_output/MAGs
reads_dir=/scratch/syersin2/Satellite_scratch/Cleaned_reads
outdir=/scratch/syersin2/Satellite_scratch/mags_output/coverm/coverm_out
TMPDIR=/scratch/syersin2/Satellite_scratch/mags_output/coverm/tmp

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
