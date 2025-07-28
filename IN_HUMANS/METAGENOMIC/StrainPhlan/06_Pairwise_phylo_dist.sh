#!/bin/bash

##############################################
# Extract the sample pairwise distances from the phylogenetic tree into a tsv file
# Margaux Creze
# 18.12.2024
##############################################

#SBATCH --partition cpu
#SBATCH --job-name 06_Pairwise_phylogenetic_distances
#SBATCH --output /scratch/mcreze/StrainPhlan_scratch/std_output/%x_%A_%j.out
#SBATCH --error /scratch/mcreze/StrainPhlan_scratch/std_output/%x_%A_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user margaux.creze@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 4
#SBATCH --mem 20G
#SBATCH --time 00:10:00
#SBATCH --array 1-697

# Module
module load gcc/12.3.0
module load python/3.8.18

# Activate conda environment
source /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/PyPhlAn/venv/bin/activate

## Variables
indir=/scratch/mcreze/StrainPhlan_scratch/StrainPhlan_output
outdir=/scratch/mcreze/StrainPhlan_scratch/StrainPhlan_output/Phylo_dist
env=/work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/PyPhlAn

mkdir -p ${outdir}

## Define array variable
# Extract the filename corresponding to this SLURM array task ID
cd ${indir}
file=$(ls RAxML_bestTree.t__SGB*.StrainPhlAn4.tre | sed -n "${SLURM_ARRAY_TASK_ID}p")
# Extract the unique identifier from the filename
SGB=$(basename "${file}" | sed 's/^RAxML_bestTree\.//' | sed 's/\.StrainPhlAn4\.tre$//')

# Debug: Print the identifier
echo "Processing identifier: $SGB"

## Pairwise phylogenetic distances
cd ${env}
python tree_pairwisedists.py -n ${indir}/RAxML_bestTree.${SGB}.StrainPhlAn4.tre ${outdir}/${SGB}_nGD.tsv

