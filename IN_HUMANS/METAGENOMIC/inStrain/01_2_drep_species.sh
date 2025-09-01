#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name drep_mags_95
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 32
#SBATCH --mem 8G
#SBATCH --time 12:00:00

# Script to dereplicate MAGs at the species level using dRep

# Module - adapt
module load gcc/11.4.0
module load miniconda3/22.11.1

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/dRep/drep

# Variables
drep_dir=/scratch/<USERS>/<Project_scratch>/dereplication_species
mags_dir=/scratch/<USERS>/<Project_scratch>/MAGs
genome_info=/scratch/<USERS>/<Project_scratch>/tables

# Dereplicate 
dRep dereplicate ${drep_dir} \
    -g ${mags_dir}/*.fa \
    --genomeInfo ${genome_info}/checkm_drep.csv \
    -p 32 \
    -pa 0.95 -sa 0.95 -nc 0.30 --S_algorithm ANIn
