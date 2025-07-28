#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=150G
#SBATCH --job-name=GTDBTK
#SBATCH --output /scratch/syersin2/mags_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/mags_scratch/std_output/%x_%j.err
#SBATCH --time 4:00:00

# Module
module load gcc/10.4.0
module load miniconda3/4.10.3

# Activate conda environment - DO NOT MODIFY!
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/GTDB_TK/gtdbtk

#### Create directories and define variables
gtdb_indir=/scratch/syersin2/mags_scratch/mags_output

## Create output directory
mkdir -p ${gtdb_indir}/GTDB

#run GTBD-Tk
gtdbtk classify_wf --genome_dir ${gtdb_indir}/MAGs \
    --out_dir ${gtdb_indir}/GTDB \
    --mash_db ${gtdb_indir}/GTDB/gtdbtk.msh \
    --extension fa \
    --cpus 16

mkdir -p users/syersin2/mags_analysis/GTDB
cp ${qc_indir}/gtdbtk.bac120.summary.tsv users/syersin2/mags_analysis/GTDB
cp ${qc_indir}/gtdbtk.log users/syersin2/mags_analysis/GTDB
cp ${qc_indir}/gtdbtk.warnings.log users/syersin2/mags_analysis/GTDB