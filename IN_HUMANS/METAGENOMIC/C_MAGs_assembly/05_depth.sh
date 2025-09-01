#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name depth
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 10G
#SBATCH --time 04:00:00
#SBATCH --array=1-XXX

# Script to obtain depth of backmapping using metabat2

## Load module
module load gcc/10.4.0
module load miniconda3/4.10.3

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/MetaBAT2/metabat2

## Variables
depth_indir=/scratch/<USERS>/<Project_scratch>/output_data/metaspades

## Array variables
cd ${depth_indir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

## Generate depth
mkdir -p ${depth_indir}/${sample_name}/${sample_name}_depth

echo "#####################################################"
echo $id " Start time : $(date -u)"
echo "#####################################################"

jgi_summarize_bam_contig_depths --outputDepth ${depth_indir}/${sample_name}/${sample_name}_depth/${sample_name}.depth \
    ${depth_indir}/${sample_name}/${sample_name}_backmapping/*.bam


echo "#####################################################"
echo $id " Finishing time : $(date -u)"
echo "#####################################################"
