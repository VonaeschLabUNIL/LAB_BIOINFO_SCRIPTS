#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name build_index
#SBATCH --output /scratch/syersin2/mags_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/mags_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 20G
#SBATCH --time 01:00:00
#SBATCH --array=1-3

## Load module
module load gcc/10.4.0
module load bowtie2/2.4.2

## Variables
index_indir=/scratch/syersin2/mags_scratch/output_data/metaspades

## Array variables
cd ${index_indir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

## Build index
mkdir -p ${index_indir}/${sample_name}/${sample_name}_index
bowtie2-build ${index_indir}/${sample_name}/${sample_name}.scaffolds.min1000.fasta ${index_indir}/${sample_name}/${sample_name}_index/${sample_name}

mkdir -p /users/syersin2/mags_analysis/${sample_name}/${sample_name}_index
cp ${index_indir}/${sample_name}/${sample_name}_index/*.bt2 /users/syersin2/mags_analysis/${sample_name}/${sample_name}_index/