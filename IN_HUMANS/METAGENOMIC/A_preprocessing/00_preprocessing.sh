#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name integrity
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --time 00:05:00
#SBATCH --array=1-XX

# Script t check intergrity of files and merge/rename files

indir=/scratch/<USERS>/<Project_scratch>/RawData
outdir=/scratch/<USERS>/<Project_scratch>/integrity

cd ${indir}
sample=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

# md5 check to verify all files integrity
cd ${sample}
md5sum -c *MD5*.txt > ${outdir}/intergrity_check_${sample}.txt

# Merge forward and reverse files sequenced twice into two single files + rename into R1/2_001
cat *_1.fq.gz > ${sample}_R1_001.fastq.gz
cat *_2.fq.gz > ${sample}_R2_001.fastq.gz
rm *_1.fq.gz
rm *_2.fq.gz
