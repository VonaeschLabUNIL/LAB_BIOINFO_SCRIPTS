#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name CheckM_QC
#SBATCH --output /users/syersin2/test_dir/std_output/%x_%j.out
#SBATCH --error /users/syersin2/test_dir/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16 
#SBATCH --mem 200G
#SBATCH --time 00:30:00

# Module
module load gcc/10.4.0
module load miniconda3/4.10.3

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/checkM/checkm

# Variables
inputfolder=/users/syersin2/test_dir/comp_genomics/genomes/genomesFASTA
outdir=/users/syersin2/test_dir/comp_genomics/QC_Taxonomy/checkM_QC
rm -r ${outdir}
mkdir ${outdir}
outfile=${outdir}/Checkm_QC_stats.tsv

# Run checkm
#export CHECKM_DATA_PATH=/path/to/my_checkm_data
checkm lineage_wf ${inputfolder} ${outdir} -x fasta -t 16 -f ${outfile} --tab_table