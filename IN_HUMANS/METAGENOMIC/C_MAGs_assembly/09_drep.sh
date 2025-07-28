#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name drep_mags
#SBATCH --output /scratch/syersin2/Satellite_scratch/transmission_dir/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Satellite_scratch/transmission_dir/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 32
#SBATCH --mem 8G
#SBATCH --time 12:00:00

# Module
module load gcc/11.4.0
module load miniconda3/22.11.1

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/dRep/drep

# Variables - set your directories
# The MAGs directory (mags_dir) is all the MAGs to be dereplicated in one folder
drep_dir=/scratch/syersin2/Satellite_scratch/transmission_dir/dereplication
mags_dir=/scratch/syersin2/Satellite_scratch/transmission_dir/MAGs
genome_info=/scratch/syersin2/Satellite_scratch/transmission_dir/tables

# Dereplicate 
# Adapt -pa (primary threshold for 1st clutser) and -sa (secondary threshold for 2nd clusters)
# For strain level dereplication: -pa 0.95 and  -sa 0.98
# For species level dereplication: -pa 0.85 and -sa 0.95
# For genus level dereplication: -pa 0.70 and -sa 0.85

dRep dereplicate ${drep_dir} \
    -g ${mags_dir}/*.fa \
    --genomeInfo ${genome_info}/checkm_drep.csv \
    -p 32 \
    -pa 0.95 -sa 0.98 -nc 0.30 --S_algorithm ANIn