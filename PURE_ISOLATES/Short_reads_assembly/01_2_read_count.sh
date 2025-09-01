#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name readCount
#SBATCH --output /scratch/<USER>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USER>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 1G
#SBATCH --time 00:05:00
#SBATCH --array=1-XX

# Variables
indir=/scratch/<USER>/<Project_scratch>/data
outdir=/scratch/<USER>/<Project_scratch>/read_count

mkdir ${outdir}
# Array variables
cd ${indir}
sample=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

zgrep -c '@LH' ${indir}/${sample}/*.fastq.gz >> ${outdir}/${sample}_PRE_READS_COUNT.txt
