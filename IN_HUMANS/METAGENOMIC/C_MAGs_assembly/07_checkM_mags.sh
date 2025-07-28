#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name CheckM_MAGs
#SBATCH --output /scratch/syersin2/mags_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/mags_scratch/std_output/%x_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user simon.yersin@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16 
#SBATCH --mem 200G
#SBATCH --time 01:00:00

# Module
module load gcc/10.4.0
module load miniconda3/4.10.3

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/checkM/checkm

# Variables
qc_indir=/scratch/syersin2/mags_scratch/mags_output

# Run checkm
mkdir -p ${qc_indir}/checkM

checkm lineage_wf ${qc_indir}/MAGs \
    ${qc_indir}/checkM \
    -x fa \
    -t 16 \
    -f ${qc_indir}/checkM_stats.tsv \
    --tab_table

mkdir -p users/syersin2/mags_analysis/checkM
cp ${qc_indir}/checkM_stats.tsv users/syersin2/mags_analysis/checkM
cp ${qc_indir}/check.log users/syersin2/mags_analysis/checkM