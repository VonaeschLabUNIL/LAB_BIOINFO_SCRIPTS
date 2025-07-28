#!/bin/bash

#SBATCH --job-name prodigal
#SBATCH --output /scratch/syersin2/Satellite_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Satellite_scratch/std_output/%x_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user simon.yersin@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 20G
#SBATCH --time 2:00:00

# Module
module load gcc/11.4.0
module load miniconda3/22.11.1

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/dRep/drep

# Variables
indir=/scratch/syersin2/Satellite_scratch/transmission_dir/tables/genomes_db
outdir=/scratch/syersin2/Satellite_scratch/transmission_dir/tables/genomes_db/prodigal

prodigal -i  ${indir}/allGenomes_v1.fasta \
    -d ${outdir}/allGenomes.fna \
    -a ${outdir}/allGenomes.faa