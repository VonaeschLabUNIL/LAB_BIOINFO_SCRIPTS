#!/bin/bash

###------------------
##SLURM options
###------------------
#SBATCH --partition cpu
#SBATCH --job-name read_length_extraction
#SBATCH --output /scratch/syersin2/%x_%j.out
#SBATCH --error /scratch/syersin2/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 10G
#SBATCH --time 00:10:00
#SBATCH --array=1-4

#EXTRACT READ LENGHT AND OTHER METRICS

# SET VARIABLES
pacbio_workdir=/users/syersin2/test_dir
pacbio_indir=/users/syersin2/test_dir/data_pacbio
pacbio_outdir=/users/syersin2/test_dir/output_pacbio/read_length
cd ${pacbio_indir}
sample_name=$(ls *.fastq.gz | sed -n ${SLURM_ARRAY_TASK_ID}p)
cd ${pacbio_workdir}

####--------------------------------------
##Calculate raw read statistics
echo -e "1. First calculate the read length"
####--------------------------------------

less ${pacbio_indir}/${sample_name} | awk '{if(NR%4==2) print length($1)}' > ${pacbio_outdir}/${sample_name}_raw_readLength.txt