#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name group_mags
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 8G
#SBATCH --time 00:10:00
#SBATCH --array=1-XX

# If necessary - script to group all MAGs into a single folder

## Variables
files=/scratch/<USERS>/<Project_scratch>/MAGs_per_samples

## Array variables
cd ${files}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

cp ${files}/${sample_name}/*.fa.gz /scratch/<USERS>/<Project_scratch>/MAGs
