#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name humann_norm
#SBATCH --output /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 2G
#SBATCH --time 00:10:00
#SBATCH --array=1-346

# Humann v.3.9

# Module
module load gcc/12.3.0
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/HUMANN/humann

# Variables
humann_workdir=/scratch/syersin2/Pastobiome_scratch/data/humann
outdir=/scratch/syersin2/Pastobiome_scratch/data/humann_join_tables

## Array variables
cd ${humann_workdir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

cd ${humann_workdir}/${sample_name}

# Normalize table in copy per millions
#Path abundance
humann_renorm_table -i ${sample_name}_pathabundance.tsv \
    -o ${sample_name}_pathabundance_cpm.tsv \
    --units cpm

#Uniref90
humann_renorm_table -i ${sample_name}_genefamilies.tsv \
    -o ${sample_name}_genefamilies_cpm.tsv \
    --units cpm

# EggNog
humann_renorm_table -i ${sample_name}_genefamilies_eggnog.tsv \
    -o ${sample_name}_genefamilies_eggnog_cpm.tsv \
    --units cpm

# GO
humann_renorm_table -i ${sample_name}_genefamilies_go.tsv \
    -o ${sample_name}_genefamilies_go_cpm.tsv \
    --units cpm

# KO
humann_renorm_table -i ${sample_name}_genefamilies_ko.tsv \
    -o ${sample_name}_genefamilies_ko_cpm.tsv \
    --units cpm

# Level4ec
humann_renorm_table -i ${sample_name}_genefamilies_level4ec.tsv \
    -o ${sample_name}_genefamilies_level4ec_cpm.tsv \
    --units cpm

# pfam
humann_renorm_table -i ${sample_name}_genefamilies_pfam.tsv \
    -o ${sample_name}_genefamilies_pfam_cpm.tsv \
    --units cpm

# RXN
humann_renorm_table -i ${sample_name}_genefamilies_rxn.tsv \
    -o ${sample_name}_genefamilies_rxn_cpm.tsv \
    --units cpm

# Normalize table in relative abundance
# Path abundance
humann_renorm_table -i ${sample_name}_pathabundance.tsv \
    -o ${sample_name}_pathabundance_relab.tsv \
    --units relab

#Uniref90
humann_renorm_table -i ${sample_name}_genefamilies.tsv \
    -o ${sample_name}_genefamilies_relab.tsv \
    --units relab

# EggNog
humann_renorm_table -i ${sample_name}_genefamilies_eggnog.tsv \
    -o ${sample_name}_genefamilies_eggnog_relab.tsv \
    --units relab

# GO
humann_renorm_table -i ${sample_name}_genefamilies_go.tsv \
    -o ${sample_name}_genefamilies_go_relab.tsv \
    --units relab

# KO
humann_renorm_table -i ${sample_name}_genefamilies_ko.tsv \
    -o ${sample_name}_genefamilies_ko_relab.tsv \
    --units relab

# Level4ec
humann_renorm_table -i ${sample_name}_genefamilies_level4ec.tsv \
    -o ${sample_name}_genefamilies_level4ec_relab.tsv \
    --units relab

# pfam
humann_renorm_table -i ${sample_name}_genefamilies_pfam.tsv \
    -o ${sample_name}_genefamilies_pfam_relab.tsv \
    --units relab

# RXN
humann_renorm_table -i ${sample_name}_genefamilies_rxn.tsv \
    -o ${sample_name}_genefamilies_rxn_relab.tsv \
    --units relab