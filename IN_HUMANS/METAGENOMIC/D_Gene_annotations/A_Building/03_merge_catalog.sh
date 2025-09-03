#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name merge
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 2G
#SBATCH --time 05:00:00

## Variables
indir=/scratch/<USERS>/<Project_scratch>/prodigal
outdir=/scratch/<USERS>/<Project_scratch>/catalogue/prodigal

mkdir -p ${outdir}

for f in ${indir}/*.fna; do
     awk 'BEGIN{RS=">"; ORS=""} NR>1{print ">"$0"\n"}' "$f"
done > ${outdir}/Gene_catalog_all.fna

gzip ${outdir}/Gene_catalog_all.fna

for f in ${indir}/*.faa; do
     awk 'BEGIN{RS=">"; ORS=""} NR>1{print ">"$0"\n"}' "$f"
done > ${outdir}/Gene_catalog_all.faa

gzip ${outdir}/Gene_catalog_all.faa
