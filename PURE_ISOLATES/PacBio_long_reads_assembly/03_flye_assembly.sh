#!/bin/bash

###------------------
##SLURM options
###------------------
#SBATCH --partition cpu
#SBATCH --job-name assembly
#SBATCH --output /users/syersin2/test_dir/std_output/%x_%j.out
#SBATCH --error /users/syersin2/test_dir/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 64G
#SBATCH --time 03:00:00
#SBATCH --array=1-4

## Variables
pacbio_workdir=/users/syersin2/test_dir/
pacbio_indir=/users/syersin2/test_dir/output_pacbio/filtered_reads
pacbio_outdir=/users/syersin2/test_dir/output_pacbio/assemblies
cd ${pacbio_indir}
sample_name=$(ls *.fastq.gz | sed -n ${SLURM_ARRAY_TASK_ID}p)
cd ${pacbio_workdir}
GENOME_SIZE=2.5m

##LOAD MODULE
module load gcc/10.4.0
module load flye/2.6 
# Fast and accurate de novo assembler for single molecule sequencing reads

##assembly
rm -r ${pacbio_workdir}/output_pacbio/assemblies/
mkdir -p ${pacbio_workdir}/output_pacbio/assemblies/${sample_name}

flye --threads 8  --iterations 5 --genome-size ${GENOME_SIZE} \
      --pacbio-raw ${pacbio_indir}/${sample_name} \
      --out-dir ${pacbio_outdir}/${sample_name}
# Flye assembler version 2.6 without option pacbio-hifi, so selected pacbio-raw
echo -e "JOB DONE"