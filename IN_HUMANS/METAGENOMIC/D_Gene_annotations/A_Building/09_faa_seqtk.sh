#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name seqtkfna
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 20G
#SBATCH --time 04:00:00

# Modules - adapt
module load gcc/12.3.0
module load seqtk/1.4

## Variables
indir=/scratch/<USERS>/<Project_scratch>/catalogue/prodigal
mmseqsdir=/scratch/<USERS>/<Project_scratch>/catalogue/mmseqs9590
outdir=/scratch/<USERS>/<Project_scratch>/catalogue/derepcat

mkdir -p ${outdir}

zcat ${indir}/Gene_catalog_all.faa | \
    seqtk subseq - ${mmseqsdir}/mmseqs9590.headers \
    > ${outdir}/Gene_catalog_derep.faa
