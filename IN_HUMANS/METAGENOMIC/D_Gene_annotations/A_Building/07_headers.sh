#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name headers
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 100M
#SBATCH --time 00:10:00

## Variables
dir=/scratch/<USERS>/<Project_scratch>/catalogue/mmseqs9590

# Extract representative sequence list
cut -f 1 ${dir}/Gene_catalog_all.mmseqs.db.tsv | sort | uniq > ${dir}/mmseqs9590.headers
