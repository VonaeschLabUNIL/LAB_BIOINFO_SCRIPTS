#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name copy_assemblies
#SBATCH --output /scratch/<USER>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USER>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --time 00:50:00
#SBATCH --array=1-XXX

# Variables
indir=/scratch/<USER>/<Project_scratch>/spades
outdir=/scratch/<USER>/<Project_scratch>/wgs_assemblies

## Array variables
cd ${indir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

cp ${indir}/${sample_name}/${sample_name}.scaffolds.min1000.fasta ${outdir}
