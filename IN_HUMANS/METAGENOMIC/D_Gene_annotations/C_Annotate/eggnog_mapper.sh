#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name 2eggnog
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 30G
#SBATCH --time 12:00:00
#SBATCH --array=1-10

# Module
module load gcc/12.3.0
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/EGGNog/eggnog

## Variables
indir=/scratch/syersin2/Afribiota_scratch/catalogue/derepcat/split_cat/Afribiota_gene_catalog_derep.faa.split
outdir=/scratch/syersin2/Afribiota_scratch/annotations/eggnog
datadir=/work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/EGGNog/database
tmpdir=/scratch/syersin2/Afribiota_scratch/tmp/eggnog
scratchdir=/scratch/syersin2/Afribiota_scratch/annotations/eggnog_scratch

# catalogue part
parts=$(ls ${indir} | sed -n ${SLURM_ARRAY_TASK_ID}p | sed 's/\.faa$//')

rm -r ${outdir}/${parts}
mkdir -p ${outdir}/${parts}

rm -r ${tmpdir}/${parts}
mkdir -p ${tmpdir}/${parts}

rm -r ${scratchdir}/${parts}
mkdir -p ${scratchdir}/${parts}

#cd ${outdir}/${parts}
# Run egg nog mapper
emapper.py -i ${indir}/${parts}.faa \
    --itype proteins \
    --output_dir ${outdir}/${parts} \
    -o EggNOG_${parts} \
    --scratch_dir ${scratchdir}/${parts} \
    --temp_dir ${tmpdir}/${parts} \
    --cpu 16 \
    --data_dir ${datadir}