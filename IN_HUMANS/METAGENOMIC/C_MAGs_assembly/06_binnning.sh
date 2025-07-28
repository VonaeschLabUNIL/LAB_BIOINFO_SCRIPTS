#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name binning
#SBATCH --output /scratch/syersin2/mags_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/mags_scratch/std_output/%x_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user simon.yersin@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 2G
#SBATCH --time 04:00:00
#SBATCH --array=1-3

## Load module
module load gcc/10.4.0
module load miniconda3/4.10.3

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/MetaBAT2/metabat2

## Variables
bin_indir=/scratch/syersin2/mags_scratch/output_data/metaspades
bin_outdir=/scratch/syersin2/mags_scratch/mags_output

## Array variables
cd ${bin_indir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

## Metagnomic binnnig
mkdir -p ${bin_outdir}/MAGs

echo "#####################################################"
echo $id " Start time : $(date -u)"
echo "#####################################################"

metabat2 -i ${bin_indir}/${sample_name}/${sample_name}.scaffolds.min1000.fasta \
    -a ${bin_indir}/${sample_name}/${sample_name}_depth/${sample_name}.depth \
    -o ${bin_outdir}/MAGs/${sample_name} \
    --minContig 2000 \
    --maxEdges 500 \
    --minCV 1 \
    --minClsSize 200000 \
    --saveCls -v

mkdir -p /users/syersin2/mags_test/mags_analysis/MAGs
cp ${bin_outdir}/MAGs/${sample_name} /users/syersin2/mags_test/mags_analysis/MAGs
cp ${bin_outdir}/MAGs/*.fa /users/syersin2/mags_test/mags_analysis/MAGs
gzip /users/syersin2/mags_test/mags_analysis/MAGs/*.fa

echo "#####################################################"
echo $id " Finishing time : $(date -u)"
echo "#####################################################"