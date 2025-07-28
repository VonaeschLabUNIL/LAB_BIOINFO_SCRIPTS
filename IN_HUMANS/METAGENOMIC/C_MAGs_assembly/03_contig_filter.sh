#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name contigs_filtering
#SBATCH --output /scratch/syersin2/mags_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/mags_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 2G
#SBATCH --time 01:00:00
#SBATCH --array=1-3

## Load modules
module load gcc/10.4.0
module load python/3.7.10
module load miniconda3/4.10.3

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/BioPython/biopython

## Variables
filter_workdir=/scratch/syersin2/mags_scratch
filter_indir=/scratch/syersin2/mags_scratch/output_data/metaspades
keep_dir=/users/syersin2/mags_test/output

## Array variables
cd ${filter_indir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)
cd ${filter_workdir}

## Run contigs filtering
python /users/syersin2/mags_test/scripts/scaffold_filter.py ${sample_name} scaffolds ${filter_indir}/${sample_name}/scaffolds.fasta ${filter_indir}/${sample_name}/ META
python /users/syersin2/mags_test/scripts/scaffold_filter.py ${sample_name} contigs ${filter_indir}/${sample_name}/contigs.fasta ${filter_indir}/${sample_name}/ META

## Get assembly stats
assembly-stats -l 500 -t <(cat ${filter_indir}/${sample_name}/${sample_name}.scaffolds.min500.fasta) > ${filter_indir}/${sample_name}/${sample_name}.min500.assembly.stats
assembly-stats -l 1000 -t <(cat ${filter_indir}/${sample_name}/${sample_name}.scaffolds.min1000.fasta) > ${filter_indir}/${sample_name}/${sample_name}.min1000.assembly.stats

## Copy important files to /users directory
cp ${filter_indir}/${sample_name}/${sample_name}.min500.assembly.stats ${keep_dir}/${sample_name}
cp ${filter_indir}/${sample_name}/${sample_name}.min1000.assembly.stats ${keep_dir}/${sample_name}
cp ${filter_indir}/${sample_name}/${sample_name}.scaffolds.min500.fasta ${keep_dir}/${sample_name}
cp ${filter_indir}/${sample_name}/${sample_name}.scaffolds.min1000.fasta ${keep_dir}/${sample_name}

gzip ${keep_dir}/${sample_name}/*.fasta