#!/bin/bash

###------------------
##SLURM options
###------------------
#SBATCH --partition cpu
#SBATCH --job-name readFiltering
#SBATCH --output /scratch/syersin2/%x_%j.out
#SBATCH --error /scratch/syersin2/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 8G
#SBATCH --time 00:10:00
#SBATCH --array=1-4

## Variables
pacbio_workdir=/users/syersin2/test_dir
pacbio_indir=/users/syersin2/test_dir/data_pacbio
pacbio_outdir=/users/syersin2/test_dir/output_pacbio/filtered_reads
cd ${pacbio_indir}
sample_name=$(ls *.fastq.gz | sed -n ${SLURM_ARRAY_TASK_ID}p)
cd ${pacbio_workdir}

MINIMUM_read_LENGTH=1000
min_mean_q=10
length_weight=1
target_bases=115000000

##LOAD MODULE
module load gcc/10.4.0
module load filtlong/0.2.0 
# Filtlong is a tool for filtering long reads by quality. It can take a set of long reads and produce a smaller, better subset.

####--------------------------------------
##Filter reads
echo -e "1. First we filter the reads"
####--------------------------------------

filtlong --min_length ${MINIMUM_read_LENGTH} \
        --min_mean_q ${min_mean_q} \
        --length_weight ${length_weight} \
        --target_bases ${target_bases}  \
        ${pacbio_indir}/${sample_name} | gzip > ${pacbio_outdir}/filtered_${sample_name}

less ${pacbio_outdir}/filtered_${sample_name} | awk '{if(NR%4==2) print length($1)}' > ${pacbio_workdir}/output_pacbio/read_length/${sample_name}_filtered_readLength.txt

#min_length: Discard any read which is shorter than MINIMUM_read_LENGTH value
#min_mean_q: Minimum mean quality threshold
#length_weight: Weight given to the length score
#target_bases: Remove the worst reads until only target_bases bp remains, set using: genome size x coverage 