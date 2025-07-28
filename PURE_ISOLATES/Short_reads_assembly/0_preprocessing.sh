#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name integrity
#SBATCH --output /scratch/syersin2/Satellite_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Satellite_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --time 00:05:00
#SBATCH --array=1-9

indir=/scratch/syersin2/Satellite_scratch/Isolates/data
outdir=/scratch/syersin2/Satellite_scratch/Isolates/integrity

cd ${indir}
sample=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

cd ${sample}
md5sum -c *MD5*.txt > ${outdir}/intergrity_check_${sample}.txt

cat *_1.fq.gz > ${sample}_R1_001.fastq.gz
cat *_2.fq.gz > ${sample}_R2_001.fastq.gz
rm *_1.fq.gz
rm *_2.fq.gz