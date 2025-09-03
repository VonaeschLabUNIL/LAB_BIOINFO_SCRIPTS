#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name mmseqs_cluster
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 200G
#SBATCH --time 08:00:00

# Module
module load gcc/12.3.0
module load mmseqs2/14-7e284

# Variable
indir=/scratch/syersin2/Afribiota_scratch/catalogue/prodigal
outdir=/scratch/syersin2/Afribiota_scratch/catalogue/mmseqs9590

mkdir -p ${outdir}
mkdir -p ${outdir}/mmseqs_tmp

mmseqs cluster ${outdir}/Afribiota_gene_catalog_all.mmseqs.db \
    ${outdir}/Afribiota_gene_catalog_all.mmseqs.db.cluster \
    ${outdir}/mmseqs_tmp \
    --compressed 1 --split-memory-limit 120G \
    --kmer-per-seq-scale 0  --kmer-per-seq 1000 -s 4 --max-seq-len 80000 --remove-tmp-files 0 --cluster-mode 2 --min-seq-id 0.95 --threads 24  \
    --cov-mode 1 -c 0.9  --spaced-kmer-mode 0  --alignment-mode 3 \
    --cluster-reassign 1 &> ${outdir}/Afribiota_gene_catalog_all.mmseqs.db.log