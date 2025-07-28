#!/bin/bash

##################################################################
# MetaPhlan 4.1.1 to profile the composition of microbial communities from metagenomic shotgun sequencing data
# Margaux Creze
# 18.12.2024
##################################################################


#SBATCH --partition cpu
#SBATCH --job-name 01_Metaphlan4.1.1
#SBATCH --output /scratch/mcreze/StrainPhlan_scratch/std_output/%x_%A_%j.out
#SBATCH --error /scratch/mcreze/StrainPhlan_scratch/std_output/%x_%A_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user margaux.creze@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 20G
#SBATCH --time 4:00:00
#SBATCH --array 1-470

# Module
module load gcc/11.4.0
module load miniconda3/22.11.1

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/MetaPhlan/metaphlan

## Variables
mpa_indir=/scratch/mcreze/StrainPhlan_scratch/Host_extracted_reads
mpa_sams=/scratch/mcreze/StrainPhlan_scratch/MetaPhlan_output/sams
mpa_profiles=/scratch/mcreze/StrainPhlan_scratch/MetaPhlan_output/profiles
mpa_bowtie=/scratch/mcreze/StrainPhlan_scratch/MetaPhlan_output/bowtie2

mkdir -p ${mpa_sams}
mkdir -p ${mpa_profiles}
mkdir -p ${mpa_bowtie}

## Array variables
cd ${mpa_indir}
sample=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

echo “###############################################”
echo ${sample} Performing metaphlan4.1.1 analysis - Start time: $(date -u)
echo “##############################################”

metaphlan ${mpa_indir}/${sample}/${sample}_Host_Extracted_R1_001.fastq.gz \
    --input_type fastq \
    --nproc 16 \
    -s ${mpa_sams}/${sample}.sam.bz2 \
    --bowtie2out ${mpa_bowtie}/${sample}.bowtie2.bz2 \
    -o ${mpa_profiles}/${sample}_metaphlan_profile.tsv \

echo “##############################################”
echo ${sample} Finishing time: $(date -u)
echo “##############################################”
