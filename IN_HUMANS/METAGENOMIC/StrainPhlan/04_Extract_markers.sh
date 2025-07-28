#!/bin/bash

##############################################
# Extract the markers from MetaPhlAn database
# Margaux Creze
# 18.12.2024
##############################################

#SBATCH --partition cpu
#SBATCH --job-name 04_Extract_markers
#SBATCH --output /scratch/mcreze/StrainPhlan_scratch/std_output/%x_%A_%j.out
#SBATCH --error /scratch/mcreze/StrainPhlan_scratch/std_output/%x_%A_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user margaux.creze@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 10
#SBATCH --mem 20G
#SBATCH --time 01:00:00
#SBATCH --array 1-2 #check this line to know how many clades in clade.txt : Thu Dec 19 15:05:41 2024: Detected 2 clades: 


# Module
module load gcc/11.4.0
module load miniconda3/22.11.1


# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/MetaPhlan/metaphlan

## Variables
indir=/scratch/mcreze/StrainPhlan_scratch/Consensus_markers
outdir_clade=/scratch/mcreze/StrainPhlan_scratch/CladeMarkers

mkdir -p ${outdir_clade}

# Define array variable
sample=$(grep 't__' clades.txt | sed -E 's/^.*(t__[^:]+):.*$/\1/' | sed -n "${SLURM_ARRAY_TASK_ID}p")

## Extract the markers from MetaPhlAn database
extract_markers.py -c ${sample} \
    -o ${outdir_clade}/