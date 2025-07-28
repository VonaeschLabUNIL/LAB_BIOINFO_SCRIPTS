#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name copy_MAGs
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 10G
#SBATCH --time 00:10:00
#SBATCH --output /scratch/syersin2/Project_scratch/std_output/%x_%j.out

## Config strept contain the list of MAGs with completeness >=80% and contamination <=10% (or other thresholds)
config=/users/syersin2/Project_name/script/List_MAGs_config.txt
# The config file was created on RStudio with the CheckM and GTDB results

mkdir -p /scratch/syersin2/Project_name/data/HQ_MAGS

for mags in $(awk '{print $1}' $config)
    do
    cp /scratch/syersin2/Project_name/data/MAGs/${mags}.fa /scratch/syersin2/Project_name/data/HQ_MAGS
done