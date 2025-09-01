#!/bin/bash

#SBATCH --job-name prodigal
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 20G
#SBATCH --time 2:00:00

# Script to run prodigal on the fasta file merging all dereplicated MAGs

# Module - adapt
module load gcc/11.4.0
module load miniconda3/22.11.1

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/dRep/drep

# Variables
indir=/scratch/<USERS>/<Project_scratch>/tables/genomes_db
outdir=/scratch/<USERS>/<Project_scratch>/tables/genomes_db/prodigal

prodigal -i  ${indir}/allGenomes_v1.fasta \
    -d ${outdir}/allGenomes.fna \
    -a ${outdir}/allGenomes.faa
