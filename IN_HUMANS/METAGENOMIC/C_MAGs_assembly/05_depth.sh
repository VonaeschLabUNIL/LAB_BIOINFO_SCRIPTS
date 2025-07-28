#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name depth
#SBATCH --output /scratch/syersin2/mags_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/mags_scratch/std_output/%x_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user simon.yersin@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 10G
#SBATCH --time 04:00:00
#SBATCH --array=1-3

## Load module
module load gcc/10.4.0
module load miniconda3/4.10.3

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/MetaBAT2/metabat2

## Variables
depth_indir=/scratch/syersin2/mags_scratch/output_data/metaspades

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

mkdir -p /users/syersin2/mags_analysis/${sample_name}/${sample_name}_depth
cp ${depth_indir}/${sample_name}/${sample_name}_depth/*.depth /users/syersin2/mags_analysis/${sample_name}/${sample_name}_depth

echo "#####################################################"
echo $id " Finishing time : $(date -u)"
echo "#####################################################"