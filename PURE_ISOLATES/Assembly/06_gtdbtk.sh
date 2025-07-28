#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name GTDBTK
#SBATCH --output /scratch/syersin2/Satellite_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Satellite_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 32
#SBATCH --mem 250G
#SBATCH --time 01:00:00

# Module
module load gcc/11.4.0
module load miniconda3/22.11.1

# Activate conda environment - DO NOT MODIFY!
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/GTDB_TK/gtdbtk

#### Create directories and define variables
inputfolder=/scratch/syersin2/Satellite_scratch/Isolates/wgs_assemblies

#Create output directory and make sure is empty
outdir=/scratch/syersin2/Satellite_scratch/Isolates/GTDB
rm -r ${outdir} 
mkdir ${outdir}

#run GTBD-Tk
gtdbtk classify_wf --genome_dir ${inputfolder} \
    --out_dir ${outdir} \
    --mash_db ${outdir}/gtdbtk.msh \
    --extension fasta \
    --cpus 32