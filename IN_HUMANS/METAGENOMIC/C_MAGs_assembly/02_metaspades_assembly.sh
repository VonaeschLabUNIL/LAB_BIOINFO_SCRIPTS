#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name metaSPAdes
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 40
#SBATCH --mem 250G
#SBATCH --time 24:00:00
#SBATCH --array=1-XXX

# Script for assembly of MAGs using metaSPAdes

## Load modules - adapt
module load gcc/10.4.0
module load spades/3.15.3
module load python/3.10.12

## Variables
spades_workdir=/scratch/<USERS>/<Project_scratch>
spades_indir=/scratch/<USERS>/<Project_scratch>/data
spades_outdir=/scratch/<USERS>/<Project_scratch>/output_data/metaspades

## Array variables
cd ${spades_indir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)
cd ${spades_workdir}

## Create directory
rm -r ${spades_workdir}/output_data/metaspades
mkdir -p ${spades_outdir}/${sample_name}

## Run metaSPAdes
spades.py --meta \
    --pe1-1 ${spades_indir}/${sample_name}/${sample_name}_FASTP_BOWTIE2_R1_001.fastq.gz \
    --pe1-2 ${spades_indir}/${sample_name}/${sample_name}_FASTP_BOWTIE2_R2_001.fastq.gz \
    -o ${spades_outdir}/${sample_name} \
    -k 21,33,55,77,99,127

# Cleaning files
rm -r ${spades_outdir}/${sample_name}/misc
rm -r ${spades_outdir}/${sample_name}/K*
rm -r ${spades_outdir}/${sample_name}/tmp

