#!/bin/bash

#SBATCH --job-name map_reads
#SBATCH --output /scratch/syersin2/Satellite_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Satellite_scratch/std_output/%x_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user simon.yersin@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 20G
#SBATCH --time 2:00:00

#Load modules
module load gcc/11.4.0
module load bowtie2/2.5.1

## Variables
index_indir=/scratch/syersin2/Satellite_scratch/transmission_dir/tables/genomes_db

## Build index
mkdir -p ${index_indir}/bt2_index
bowtie2-build --threads 16 ${index_indir}/allGenomes_v1.fasta ${index_indir}/bt2_index/allGenomes_index