#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name mmseqs_tsv
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 4
#SBATCH --mem 2G
#SBATCH --time 00:30:00

# Module
module load gcc/12.3.0
module load mmseqs2/14-7e284

# Variable
outdir=/scratch/syersin2/Afribiota_scratch/catalogue/mmseqs9590

mmseqs createtsv ${outdir}/Afribiota_gene_catalog_all.mmseqs.db \
    ${outdir}/Afribiota_gene_catalog_all.mmseqs.db \
    ${outdir}/Afribiota_gene_catalog_all.mmseqs.db.cluster \
    ${outdir}/Afribiota_gene_catalog_all.mmseqs.db.tsv