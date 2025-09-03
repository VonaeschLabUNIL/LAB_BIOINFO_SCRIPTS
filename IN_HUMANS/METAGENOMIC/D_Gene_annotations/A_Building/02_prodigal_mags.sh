#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name prodigal_mags2
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 1G
#SBATCH --time 00:10:00
#SBATCH --array=1-57

# Module
module load gcc/12.3.0
module load prodigal/2.6.3

## Variables
indir=/scratch/syersin2/Afribiota_scratch/MAGs
outdir=/scratch/syersin2/Afribiota_scratch/prodigal

sample=$(ls ${indir} | sed -n ${SLURM_ARRAY_TASK_ID}p)

# Create output directory if it doesn't exist
mkdir -p ${outdir}

# Loop over all .fa files
for filepath in ${indir}/${sample}/*.fa; do
    mags_name=$(basename ${filepath} .fa)
    sample_name=$(echo $mags_name | cut -d'.' -f1)
    mag_id=$(echo $mags_name | cut -d'.' -f2) # Extract mags number 

    echo "Running Prodigal on $mags_name..."

    prodigal -a ${outdir}/${mags_name}.faa \
             -f gff \
             -i ${filepath} \
             -d ${outdir}/${mags_name}.fna \
             -o ${outdir}/${mags_name}.gff \
             -c -q \
             -p single
    
    # Rename headers to include _MAG${mag_id} which correspond to the number
    sed -i "s/^>${sample_name}/>${sample_name}_MAG${mag_id}/" ${outdir}/${mags_name}.faa
    sed -i "s/^>${sample_name}/>${sample_name}_MAG${mag_id}/" ${outdir}/${mags_name}.fna

done