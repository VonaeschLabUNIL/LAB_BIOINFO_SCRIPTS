#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name cazymes
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 10G
#SBATCH --time 12:00:00
#SBATCH --array=1-10

# Module
module load gcc/12.3.0
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/dbCAN/dbcan

## Variables
indir=/scratch/syersin2/Afribiota_scratch/catalogue/derepcat/split_cat/Afribiota_gene_catalog_derep.faa.split
outdir=/scratch/syersin2/Afribiota_scratch/annotations/cazymes
dbdir=/work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/dbCAN/database
pyscript=/users/syersin2/Afribiota/PEData/scripts/D_gene_catalog/C_Annotate

# catalogue part
parts=$(ls ${indir} | sed -n ${SLURM_ARRAY_TASK_ID}p | sed 's/\.faa$//')

rm -r ${outdir}/${parts}
mkdir -p ${outdir}/${parts}

# Run DBCan to profile cazymes
run_dbcan ${indir}/${parts}.faa protein \
    --verbose \
    --dia_cpu 16 \
    --hmm_cpu 16 \
    --out_dir ${outdir}/${parts} \
    --out_pre ${parts} \
    --db_dir ${dbdir} \
    --dbcan_thread 4 \
    --tf_cpu 4

# simplify ouput: 
#python ${pyscript}/dbcan_simplify.py ${outdir}/overview.txt > ${outdir}/Afribiota_cazy_resulst.tsv
