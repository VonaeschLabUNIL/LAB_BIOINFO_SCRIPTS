#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name backmapping
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 48
#SBATCH --mem 250G
#SBATCH --time 48:00:00
#SBATCH --array=1-XXX

# Script to align the metagenomic reads to the indexed scaffolds using bowtie2

## Load module - adapt
module load gcc/10.4.0
module load bowtie2/2.4.2
module load samtools/1.15.1

## Variables
index_indir=/scratch/<USERS>/<Project_scratch>/output_data/metaspades
reads_indir=/scratch/<USERS>/<Project_scratch>/data
tmp=/scratch/<USERS>/<Project_scratch>/tmp

## Array variables
cd ${index_indir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

## Backmapping
mkdir -p ${index_indir}/${sample_name}/${sample_name}_backmapping

echo "#####################################################"
echo $id " Start time of the loop : $(date -u)"
echo "#####################################################"

for reads in $(ls)
    do
    echo "Alignment of " ${reads} " on " ${sample_name} " is running and starts at $(date -u)" 
    bowtie2 -x ${index_indir}/${sample_name}/${sample_name}_index/${sample_name} \
        -1 ${reads_indir}/${reads}/${reads}_FASTP_BOWTIE2_R1_001.fastq.gz \
        -2 ${reads_indir}/${reads}/${reads}_FASTP_BOWTIE2_R2_001.fastq.gz \
        -S ${index_indir}/${sample_name}/${sample_name}_backmapping/${reads}_mapped_to_${sample_name}.sam \
        --threads 48
    echo "Changing alignment of " ${reads} " on " ${sample_name} " to sorted bam file at $(date -u)"
    samtools view -F 4 -bh ${index_indir}/${sample_name}/${sample_name}_backmapping/${reads}_mapped_to_${sample_name}.sam \
        | samtools sort -O bam -@ 4 -m 4G -T ${tmp} > ${index_indir}/${sample_name}/${sample_name}_backmapping/${reads}_mapped_to_${sample_name}.bam
    rm ${index_indir}/${sample_name}/${sample_name}_backmapping/${reads}_mapped_to_${sample_name}.sam
    echo "Alignment of " ${reads} " on " ${sample_name} " is completed at $(date -u)"
done

echo "#####################################################"
echo $id " Finishing time of the loop : $(date -u)"
echo "#####################################################"
