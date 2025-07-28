#!/bin/bash

##################################################################
# Generate a marker file for each sample
# Margaux Creze
# 18.12.2024
##################################################################

#SBATCH --partition cpu
#SBATCH --job-name 02_Sample_to_markers
#SBATCH --output /scratch/mcreze/StrainPhlan_scratch/std_output/%x_%A_%j.out
#SBATCH --error /scratch/mcreze/StrainPhlan_scratch/std_output/%x_%A_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user margaux.creze@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 4
#SBATCH --mem 12G
#SBATCH --time 00:10:00

# Module
module load gcc/11.4.0
module load miniconda3/22.11.1
module load samtools

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/MetaPhlan/metaphlan

## Variables
indir=/scratch/mcreze/StrainPhlan_scratch/MetaPhlan_output/sams
outdir=/scratch/mcreze/StrainPhlan_scratch/Consensus_markers

rm -r ${outdir}

mkdir -p ${outdir}

# Generate the marker files
sample2markers.py -i ${indir}/*.sam.bz2 \
    --nproc 10 \
    -o ${outdir}

