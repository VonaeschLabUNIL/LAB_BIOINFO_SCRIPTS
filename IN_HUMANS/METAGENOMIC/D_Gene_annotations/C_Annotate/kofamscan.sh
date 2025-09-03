#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name kofamscan_split
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 12
#SBATCH --mem 12G
#SBATCH --time 06:00:00
#SBATCH --array=1-10

# Module
module load gcc/12.3.0
module load parallel/20220522
module load ruby/3.3.0
module load hmmer/3.4

## Variables
KOFAM_DIR=/work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/KOFAM/kofam_scan-1.3.0
indir=/scratch/syersin2/Afribiota_scratch/catalogue/derepcat/split_cat/Afribiota_gene_catalog_derep.faa.split
outdir=/scratch/syersin2/Afribiota_scratch/annotations/kofamscan
tmpdir=/scratch/syersin2/Afribiota_scratch/tmp

# catalogue part
parts=$(ls ${indir} | sed -n ${SLURM_ARRAY_TASK_ID}p | sed 's/\.faa$//')

rm -r ${outdir}/${parts}
mkdir -p ${outdir}/${parts}

# Run Kofam scan
${KOFAM_DIR}/exec_annotation -o ${outdir}/${parts}/${parts}_kofam.txt \
    --tmp-dir=${tmpdir}/${parts} \
    --cpu=12 \
    ${indir}/${parts}.faa