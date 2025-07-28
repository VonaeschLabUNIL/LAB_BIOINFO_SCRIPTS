#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=150G
#SBATCH --job-name=GTDBTK
#SBATCH --output=/users/syersin2/test_dir/std_output/%x_%j.out
#SBATCH --error=/users/syersin2/test_dir/std_output/%x_%j.err
#SBATCH --time 4:00:00
#SBATCH --export=None

# Module
module load gcc/10.4.0
module load miniconda3/4.10.3

# Activate conda environment - DO NOT MODIFY!
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/GTDB_TK/gtdbtk

#### Create directories and define variables
inputfolder=/users/syersin2/test_dir/comp_genomics/genomes/genomesFASTA

#Create output directory and make sure is empty
outdir=/users/syersin2/test_dir/comp_genomics/QC_Taxonomy/GTDB_out
rm -r ${outdir} 
mkdir ${outdir}

#run GTBD-Tk
gtdbtk classify_wf --genome_dir ${inputfolder} --out_dir ${outdir} --mash_db ${outdir}/gtdbtk.msh --extension fasta --cpus 16