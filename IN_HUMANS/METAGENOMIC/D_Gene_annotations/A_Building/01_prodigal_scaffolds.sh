#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name prodigal
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 300M
#SBATCH --time 01:00:00
#SBATCH --array=1-57

# Module
module load gcc/12.3.0
module load prodigal/2.6.3

## Variables
indir=/scratch/syersin2/Afribiota_scratch/metaspades
outdir=/scratch/syersin2/Afribiota_scratch/prodigal

sample=$(ls ${indir} | sed -n ${SLURM_ARRAY_TASK_ID}p)

mkdir -p ${outdir}

prodigal -a ${outdir}/${sample}.faa \
    -f gff \
    -i  ${indir}/${sample}/${sample}.scaffolds.min500.fasta \
    -d ${outdir}/${sample}.fna \
    -o ${outdir}/${sample}.gff \
    -c -q \
    -p meta

# Rename headers to have unique sequence headers
# Here we add _METAG in the sequence header to know that this sequence came from the assembled reads
sed -i "s/^>${sample}/>${sample}_METAG/" ${outdir}/${sample}.faa
sed -i "s/^>${sample}/>${sample}_METAG/" ${outdir}/${sample}.fna