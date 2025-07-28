#!/bin/bash

##################################################################
# Extracting clade names from the marker files
# Margaux Creze
# 18.12.2024
##################################################################

#SBATCH --partition cpu
#SBATCH --job-name 03_Clade_name
#SBATCH --output /scratch/mcreze/StrainPhlan_scratch/std_output/%x_%A_%j.out
#SBATCH --error /scratch/mcreze/StrainPhlan_scratch/std_output/%x_%A_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user margaux.creze@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 10
#SBATCH --mem 20G
#SBATCH --time 4:00:00

# Module
module load gcc/11.4.0
module load miniconda3/22.11.1

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/MetaPhlan/metaphlan

## Variables
indir=/scratch/mcreze/StrainPhlan_scratch/Consensus_markers

## extracting clade names
strainphlan -s ${indir}/*.json.bz2 \
    --print_clades_only \
    -o . \
    --nproc 10 > clades.txt