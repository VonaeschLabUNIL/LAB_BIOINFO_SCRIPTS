#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name group_mags
#SBATCH --output /scratch/syersin2/Satellite_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Satellite_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 8G
#SBATCH --time 00:10:00
#SBATCH --array=1-129

## Variables
files=/scratch/syersin2/Satellite_scratch/transmission_dir/MAGs_per_samples

## Array variables
cd ${files}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

cp ${files}/${sample_name}/*.fa.gz /scratch/syersin2/Satellite_scratch/transmission_dir/MAGs
