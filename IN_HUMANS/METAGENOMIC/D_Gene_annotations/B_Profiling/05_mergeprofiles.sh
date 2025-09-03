#!/bin/bash
#SBATCH --job-name=mergeprof
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=04:00:00

# Load necessary modules - adapt
module load gcc/12.3.0
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/SushiCounter/counter

## Variables
indir=/scratch/<USERS>/<Project_scratch>/catalogue/profiles
outdir=/scratch/<USERS>/<Project_scratch>/catalogue/profiles/merged
mkdir -p ${outdir}

sushicounter mergeprofiles -i ${indir}/*.genecount.profile -o ${outdir}/Project_
