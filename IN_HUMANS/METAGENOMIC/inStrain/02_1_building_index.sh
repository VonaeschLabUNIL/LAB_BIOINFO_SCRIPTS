#!/bin/bash

#SBATCH --job-name index
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 20G
#SBATCH --time 2:00:00

# Script to index fasta file of all dereplicated MAGs using bowtie2

#Load modules - adpat
module load gcc/11.4.0
module load bowtie2/2.5.1

## Variables
index_indir=/scratch/<USERS>/<Project_scratch>/tables/genomes_db

## Build index
mkdir -p ${index_indir}/bt2_index
bowtie2-build --threads 16 ${index_indir}/allGenomes_v1.fasta ${index_indir}/bt2_index/allGenomes_index
