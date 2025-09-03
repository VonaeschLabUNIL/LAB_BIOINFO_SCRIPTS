#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name zip
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 2G
#SBATCH --time 05:00:00

## Variables
indir=/scratch/syersin2/Afribiota_scratch/prodigal
outdir=/scratch/syersin2/Afribiota_scratch/catalogue/prodigal

mkdir -p ${outdir}

# for f in ${indir}/*.fna; do
#     awk 'BEGIN{RS=">"; ORS=""} NR>1{print ">"$0"\n"}' "$f"
# done > ${outdir}/Afribiota_gene_catalog_all.fna

#gzip ${outdir}/Afribiota_gene_catalog_all.fna

# for f in ${indir}/*.faa; do
#     awk 'BEGIN{RS=">"; ORS=""} NR>1{print ">"$0"\n"}' "$f"
# done > ${outdir}/Afribiota_gene_catalog_all.faa

#gzip ${outdir}/Afribiota_gene_catalog_all.faa

gzip ${indir}/*.faa
gzip ${indir}/*.fna