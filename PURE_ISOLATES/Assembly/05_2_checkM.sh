#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name CheckM
#SBATCH --output /scratch/syersin2/Satellite_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Satellite_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 50G
#SBATCH --time 01:00:00

# Module
module load gcc/11.4.0
module load miniconda3/22.11.1

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/checkM/checkm

# Variables
indir=/scratch/syersin2/Satellite_scratch/Isolates/wgs_assemblies
outdir=/scratch/syersin2/Satellite_scratch/Isolates/checkm

# Run checkm
mkdir -p ${outdir}

checkm lineage_wf ${indir} \
    ${outdir} \
    -x fasta \
    -t 16 \
    -f ${outdir}/WGS_assemblies_checkM_stats.tsv \
    --tab_table

# Saving files 
#cd ${qc_indir}/checkM/${sample_name}
#rename -v checkm "${sample_name}" checkm.log
#mkdir -p /users/syersin2/Satellite/output/mags_analysis/checkM
#cp ${qc_indir}/checkM/${sample_name}/${sample_name}_checkM_stats.tsv /users/syersin2/Satellite/output/mags_analysis/checkM
#cp ${qc_indir}/checkM/${sample_name}/${sample_name}.log /users/syersin2/Satellite/logs