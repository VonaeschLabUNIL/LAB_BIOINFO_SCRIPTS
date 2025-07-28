#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name scaffolds_filtering
#SBATCH --output /scratch/syersin2/Satellite_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Satellite_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 20G
#SBATCH --time 00:30:00
#SBATCH --array=9

## Load modules
module load gcc/11.4.0
module load python/3.7.17
module load miniconda3/22.11.1

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/BioPython/biopython

## Variables
filter_indir=/scratch/syersin2/Satellite_scratch/Isolates/spades

## Array variables
cd ${filter_indir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)


## Run contigs filtering
python /users/syersin2/Satellite/scripts/Isolates/WGS/scaffold_filter.py ${sample_name} scaffolds ${filter_indir}/${sample_name}/scaffolds.fasta ${filter_indir}/${sample_name}/ ISO
python /users/syersin2/Satellite/scripts/Isolates/WGS/scaffold_filter.py ${sample_name} contigs ${filter_indir}/${sample_name}/contigs.fasta ${filter_indir}/${sample_name}/ ISO

## Get assembly stats
assembly-stats -l 200 -t <(cat ${filter_indir}/${sample_name}/${sample_name}.scaffolds.min200.fasta) > ${filter_indir}/${sample_name}/${sample_name}.min200.assembly.stats
assembly-stats -l 1000 -t <(cat ${filter_indir}/${sample_name}/${sample_name}.scaffolds.min1000.fasta) > ${filter_indir}/${sample_name}/${sample_name}.min1000.assembly.stats