#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name merge_metaphlan
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 8G
#SBATCH --time 00:15:00
#SBATCH --output /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.err

# Module
module load gcc/11.4.0
module load miniconda3/22.11.1

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/MetaPhlan/metaphlan

cd /users/syersin2/Pastobiome/data/Metaphlan
mkdir MERGED


merge_metaphlan_tables.py *_metaphlan4.txt > ./MERGED/PASTOBIOME_metaphlan_relab.txt
merge_metaphlan_tables_abs.py *_metaphlan4.txt > ./MERGED/PASTOBIOME_metaphlan_abs.txt

cd /users/syersin2/Pastobiome/data/Metaphlan/GTDB
merge_metaphlan_tables.py --gtdb_profiles *_gtdb.txt > /users/syersin2/Pastobiome/data/Metaphlan/MERGED/PASTOBIOME_metaphlan_gtdb.txt