#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name spades
#SBATCH --output /scratch/<USER>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USER>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 50G
#SBATCH --time 01:00:00
#SBATCH --array=1-XXX

## Load modules - adapt
module load gcc/11.4.0
module load spades/3.15.5
module load python/3.10.13

# Variables
indir=/scratch/<USER>/<Project_scratch>/cleaned_reads
outdir=/scratch/<USER>/<Project_scratch>/spades

## Array variables
cd ${indir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

## Create directory
rm -r ${outdir}/${sample_name}

spades.py --pe-1 ${indir}/${sample_name}/${sample_name}_FASTP_R1_001.fastq.gz \
    --pe-2 ${indir}/${sample_name}/${sample_name}_FASTP_R2_001.fastq.gz \
    --threads 32 -m 50 \
    --isolate \
    -k 21,33,55,77,99,127 \
    -o ${outdir}/${sample_name}

# Cleaning files
rm -r ${outdir}/${sample_name}/misc
rm -r ${outdir}/${sample_name}/K*
rm -r ${outdir}/${sample_name}/tmp
