#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name keggdecoder
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 1G
#SBATCH --time 01:00:00

# Module
module load gcc/12.3.0
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/KEGGDecoder/keggdecoder

## Variables
indir=/scratch/syersin2/Afribiota_scratch/annotations/kofamscan
outdir=/scratch/syersin2/Afribiota_scratch/annotations/kofamscan/keggdecoder

rm -r ${outdir}
mkdir -p ${outdir}

KEGG-decoder -i ${indir}/Afribiota_kofamscan_merged.txt \
    -o ${outdir}/FUNCTION_OUT.list \
    -v static