#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name CheckM
#SBATCH --output /scratch/<USER>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USER>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 50G
#SBATCH --time 01:00:00

# Module - adapt
module load gcc/11.4.0
module load miniconda3/22.11.1

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/checkM/checkm

# Variables
indir=/scratch/<USER>/<Project_scratch>/wgs_assemblies
outdir=/scratch/<USER>/<Project_scratch>/checkm

# Run checkm
mkdir -p ${outdir}

checkm lineage_wf ${indir} \
    ${outdir} \
    -x fasta \
    -t 16 \
    -f ${outdir}/WGS_assemblies_checkM_stats.tsv \
    --tab_table
