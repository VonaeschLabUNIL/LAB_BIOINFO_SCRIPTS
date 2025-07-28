#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name copy_assemblies
#SBATCH --output /scratch/syersin2/Satellite_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Satellite_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --time 00:50:00
#SBATCH --array=1-9

# Variables
indir=/scratch/syersin2/Satellite_scratch/Isolates/spades
outdir=/scratch/syersin2/Satellite_scratch/Isolates/wgs_assemblies

## Array variables
cd ${indir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

cp ${indir}/${sample_name}/${sample_name}.scaffolds.min1000.fasta ${outdir}