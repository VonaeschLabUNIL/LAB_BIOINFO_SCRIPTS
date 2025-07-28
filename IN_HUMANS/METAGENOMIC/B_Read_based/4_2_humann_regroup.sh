#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name humann_regroup
#SBATCH --output /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 5G
#SBATCH --time 00:05:00
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

# Change uniref90 to other systems:
# MetaCyc Reactions: rxn
humann_regroup_table -i ${sample_name}_genefamilies.tsv \
    -g uniref90_rxn \
    -o ${sample_name}_genefamilies_rxn.tsv

# Gene Ontology: go
humann_regroup_table -i ${sample_name}_genefamilies.tsv \
    -g uniref90_go \
    -o ${sample_name}_genefamilies_go.tsv

# Kegg Orthogroups: ko
humann_regroup_table -i ${sample_name}_genefamilies.tsv \
    -g uniref90_ko \
    -o ${sample_name}_genefamilies_ko.tsv

# Level-4 enzyme commission (EC) categories: level4ec
humann_regroup_table -i ${sample_name}_genefamilies.tsv \
    -g uniref90_level4ec \
    -o ${sample_name}_genefamilies_level4ec.tsv

# Pfam domains: pfam
humann_regroup_table -i ${sample_name}_genefamilies.tsv \
    -g uniref90_pfam \
    -o ${sample_name}_genefamilies_pfam.tsv

# EggNOG: eggnog
humann_regroup_table -i ${sample_name}_genefamilies.tsv \
    -g uniref90_eggnog \
    -o ${sample_name}_genefamilies_eggnog.tsv