#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name metaphlan_gtdb
#SBATCH --output /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.err\
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 4
#SBATCH --mem 20G
#SBATCH --time 00:15:00
#SBATCH --array=1-346

# Module
module load gcc/11.4.0
module load miniconda3/22.11.1

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/MetaPhlan/metaphlan

## Variables
mpa_workdir=/users/syersin2/Pastobiome/data/Metaphlan
datadir=/scratch/syersin2/Pastobiome_scratch/data/bw_cleaned_reads

## Array variables
cd ${datadir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

## Change to GTDB taxonomy
mkdir ${mpa_workdir}/GTDB
sgb_to_gtdb_profile.py -i ${mpa_workdir}/${sample_name}_metaphlan4.txt \
    -o ${mpa_workdir}/GTDB/${sample_name}_gtdb.txt