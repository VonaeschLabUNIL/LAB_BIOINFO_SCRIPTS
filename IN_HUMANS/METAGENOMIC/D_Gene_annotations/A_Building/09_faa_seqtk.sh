#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name seqtkfna
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 20G
#SBATCH --time 04:00:00

# Module
module load gcc/12.3.0
module load seqtk/1.4

## Variables
indir=/scratch/syersin2/Afribiota_scratch/catalogue/prodigal
mmseqsdir=/scratch/syersin2/Afribiota_scratch/catalogue/mmseqs9590
outdir=/scratch/syersin2/Afribiota_scratch/catalogue/derepcat

mkdir -p ${outdir}

zcat ${indir}/Afribiota_gene_catalog_all.faa | \
    seqtk subseq - ${mmseqsdir}/mmseqs9590.headers \
    > ${outdir}/Afribiota_gene_catalog_derep.faa
