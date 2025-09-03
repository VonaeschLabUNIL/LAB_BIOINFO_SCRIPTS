#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name mmseqs_tsv
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 4
#SBATCH --mem 2G
#SBATCH --time 00:30:00

# Modules - adapt
module load gcc/12.3.0
module load mmseqs2/14-7e284

# Variable
outdir=/scratch/<USERS>/<Project_scratch>/catalogue/mmseqs9590

mmseqs createtsv ${outdir}/Gene_catalog_all.mmseqs.db \
    ${outdir}/Gene_catalog_all.mmseqs.db \
    ${outdir}/Gene_catalog_all.mmseqs.db.cluster \
    ${outdir}/Gene_catalog_all.mmseqs.db.tsv
