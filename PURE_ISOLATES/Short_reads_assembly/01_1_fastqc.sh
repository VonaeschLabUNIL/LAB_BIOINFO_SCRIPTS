#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name qc
#SBATCH --output /scratch/<USER>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USER>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --time 00:15:00
#SBATCH --array=1-9

## Load modules - adapt
module load gcc/11.4.0
module load fastqc/0.12.1

# Variables
indir=/scratch/<USER>/<Project_scratch>/data
outdir=/scratch/<USER>/<Project_scratch>/QC

# Array variables
cd ${indir}
sample=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

# Run
mkdir ${outdir} 
fastqc -o ${outdir} \
    ${indir}/${sample}/${sample}_R1_001.fastq.gz \
    ${indir}/${sample}/${sample}_R2_001.fastq.gz
