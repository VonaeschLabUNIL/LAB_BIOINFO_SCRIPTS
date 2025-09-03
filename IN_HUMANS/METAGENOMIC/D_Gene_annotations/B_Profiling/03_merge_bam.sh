#!/bin/bash
#SBATCH --job-name=merge_bam
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=20G
#SBATCH --time=04:00:00
#SBATCH --array=4,8,35,37

# Load necessary modules
module load gcc/12.3.0
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/SushiCounter/counter

## Variables
indir=/scratch/syersin2/Afribiota_scratch/catalogue/alignment
logdir=/scratch/syersin2/Afribiota_scratch/catalogue/log

mkdir -p ${logdir}

## Array variables
sample=$(ls ${indir} | sed -n ${SLURM_ARRAY_TASK_ID}p)

sushicounter mergebam -i1 ${indir}/${sample}/${sample}_r1.bam \
    -i2 ${indir}/${sample}/${sample}_r2.bam \
    -t 2 \
    -o ${indir}/${sample}/${sample}.a45.i95c080.bam \
    -i 0.95 -a 45 -c 0.8 -u &> ${logdir}/${sample}.mergebam.log