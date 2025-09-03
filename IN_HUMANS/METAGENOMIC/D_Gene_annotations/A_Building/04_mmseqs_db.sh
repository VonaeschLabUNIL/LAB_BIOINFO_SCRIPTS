#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name mmseqs_db
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 10G
#SBATCH --time 00:10:00

# Modules - adapt
module load gcc/12.3.0
module load mmseqs2/14-7e284

# Variable
indir=/scratch/<USERS>/<Project_scratch>/catalogue/prodigal
outdir=/scratch/<USERS>/<Project_scratch>/catalogue/mmseqs9590

mkdir -p ${outdir}

# dbtyp 2 is for amino acid
mmseqs createdb ${indir}/Gene_catalog_all.fna.gz \
    ${outdir}/Gene_catalog_all.mmseqs.db \
    --dbtype 2 --shuffle 0

# From output:
# MMseqs Version:       	14-7e284
# Database type         	2
# Shuffle input database	false
# Createdb mode         	0
# Write lookup file     	1
# Offset of numeric ids 	0
# Compressed            	0
# Verbosity             	3
