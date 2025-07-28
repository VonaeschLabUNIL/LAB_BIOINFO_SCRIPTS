#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name readCount
#SBATCH --output /scratch/syersin2/Satellite_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Satellite_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 1G
#SBATCH --time 00:05:00
#SBATCH --array=1-9

# Variables
indir=/scratch/syersin2/Satellite_scratch/Isolates/data
outdir=/scratch/syersin2/Satellite_scratch/Isolates/read_count

mkdir ${outdir}
# Array variables
cd ${indir}
sample=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

zgrep -c '@LH' ${indir}/${sample}/*.fastq.gz >> ${outdir}/${sample}_PRE_READS_COUNT.txt