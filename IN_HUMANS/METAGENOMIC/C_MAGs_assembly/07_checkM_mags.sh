#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name CheckM_MAGs
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16 
#SBATCH --mem 200G
#SBATCH --time 01:00:00

# Script to check quality of the MAGs using checkM

# Module - adapt
module load gcc/10.4.0
module load miniconda3/4.10.3

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/checkM/checkm

# Variables
qc_indir=/scratch/<USERS>/<Project_scratch>/mags_output

# Run checkm
mkdir -p ${qc_indir}/checkM

checkm lineage_wf ${qc_indir}/MAGs \
    ${qc_indir}/checkM \
    -x fa \
    -t 16 \
    -f ${qc_indir}/checkM_stats.tsv \
    --tab_table
