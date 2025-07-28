#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name metaphlan
#SBATCH --output /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 50G
#SBATCH --time 00:45:00
#SBATCH --array=1-346

# Module
module load gcc/11.4.0
module load miniconda3/22.11.1

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/MetaPhlan/metaphlan

# Variables
mpa_workdir=/users/syersin2/Pastobiome/data/Metaphlan
datadir=/scratch/syersin2/Pastobiome_scratch/data/bw_cleaned_reads

## Array variables
cd ${datadir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

echo "#####################################################"
echo $id " Start time of the loop : $(date -u)"
echo "Performing metaphlan4 analysis on sample": ${sample_name}
echo "#####################################################"

metaphlan ${datadir}/${sample_name}/${sample_name}_bowtie2_R1_001.fastq.gz \
    --nproc 24 --no_map -t rel_ab_w_read_stats \
    --input_type fastq \
    --ignore_eukaryotes \
    -o ${mpa_workdir}/${sample_name}_metaphlan4.txt


echo "#####################################################"
echo $id " Finish time of the loop : $(date -u)"
echo "#####################################################"