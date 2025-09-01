#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name binning
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 2G
#SBATCH --time 04:00:00
#SBATCH --array=1-XXX

# Script to bin scaffold into MAGs using metabat2

## Load module - adapt
module load gcc/10.4.0
module load miniconda3/4.10.3

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/MetaBAT2/metabat2

## Variables
bin_indir=/scratch/<USERS>/<Project_scratch>/output_data/metaspades
bin_outdir=/scratch/<USERS>/<Project_scratch>/mags_output

## Array variables
cd ${bin_indir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

## Metagnomic binnnig
mkdir -p ${bin_outdir}/MAGs

echo "#####################################################"
echo $id " Start time : $(date -u)"
echo "#####################################################"

metabat2 -i ${bin_indir}/${sample_name}/${sample_name}.scaffolds.min1000.fasta \
    -a ${bin_indir}/${sample_name}/${sample_name}_depth/${sample_name}.depth \
    -o ${bin_outdir}/MAGs/${sample_name} \
    --minContig 2000 \
    --maxEdges 500 \
    --minCV 1 \
    --minClsSize 200000 \
    --saveCls -v

echo "#####################################################"
echo $id " Finishing time : $(date -u)"
echo "#####################################################"
