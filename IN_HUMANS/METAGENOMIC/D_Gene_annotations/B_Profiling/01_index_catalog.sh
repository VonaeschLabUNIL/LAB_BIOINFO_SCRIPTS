#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name index_cat
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 10G
#SBATCH --time 02:00:00

# Load necessary modules
module load gcc/12.3.0
module load bwa/0.7.17

# Variables
indir=/scratch/syersin2/Afribiota_scratch/catalogue/derepcat

## Index gene catalog
cd ${indir}
bwa index Afribiota_gene_catalog_derep.fna