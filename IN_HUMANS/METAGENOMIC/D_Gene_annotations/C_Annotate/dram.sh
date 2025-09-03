#!/bin/bash

#SBATCH --job-name DRAM
#SBATCH --partition cpu
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 10
#SBATCH --mem 50G
#SBATCH --time 08:00:00
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --array=1

# Module
module load gcc/12.3.0
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/DRAM/dram

## Variables
indir=/scratch/syersin2/Afribiota_scratch/catalogue/derepcat/Afribiota_gene_catalog_derep.fna.split
outdir=/scratch/syersin2/Afribiota_scratch/annotations/dram

# catalogue part
parts=$(ls ${indir} | sed -n ${SLURM_ARRAY_TASK_ID}p)

rm -r ${outdir}/${parts}
mkdir -p ${outdir}/${parts}
cd ${outdir}/${parts}

#Execute DRAM
## Annotate
DRAM.py annotate \
  -i ${indir}/${parts} \
  -o ${outdir}/${parts}/${parts}_dram_annotations \
  --threads 10 \
  --skip_trnascan \
  --min_contig_size 0

## Distill
# DRAM.py distill -i ${outdir}/annotations.tsv \
#     -o ${outdir}/Afribiota_dram_distill
