#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name humann
#SBATCH --output /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 40G
#SBATCH --time 12:00:00
#SBATCH --array=3,227

# Humann v.3.9

# Module
module load gcc/12.3.0
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/HUMANN/humann

# Variables
mpa_workdir=/users/syersin2/Pastobiome/data/Metaphlan
humann_workdir=/scratch/syersin2/Pastobiome_scratch/data/humann
datadir=/scratch/syersin2/Pastobiome_scratch/data/bw_cleaned_reads
outdir=/scratch/syersin2/Pastobiome_scratch/data/humann_join_tables

## Array variables
cd ${datadir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)


echo "#####################################################"
echo $id " Start time : $(date -u)"
echo "Performing humann analysis on sample": ${sample_name}
echo "#####################################################"

rm -r ${humann_workdir}/${sample_name}
mkdir -p ${humann_workdir}/${sample_name}

humann -i ${datadir}/${sample_name}/${sample_name}_bowtie2_R1_001.fastq.gz\
    --output-basename ${sample_name} \
    -o ${humann_workdir}/${sample_name} \
    --output-max-decimals 2 \
    --o-log ${humann_workdir}/${sample_name}/${sample_name}.log \
    --taxonomic-profile ${mpa_workdir}/${sample_name}_metaphlan4.txt \
    --threads 8 \
    --remove-temp-output

echo "#####################################################"
echo $id " Finish time of the loop : $(date -u)"
echo "#####################################################"