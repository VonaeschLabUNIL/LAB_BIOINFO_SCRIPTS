#!/bin/bash
#SBATCH --job-name=normfmg
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100M
#SBATCH --time=00:10:00

# Load necessary modules
module load python/3.12.1

## Variables
indir=/scratch/syersin2/Afribiota_scratch/catalogue/profiles/merged
mgdir=/scratch/syersin2/Afribiota_scratch/catalogue/fmg
logdir=/scratch/syersin2/Afribiota_scratch/catalogue/log
scriptdir=/users/syersin2/Afribiota/PEData/scripts/D_gene_catalog

python ${scriptdir}/normalise_by_motus_v3.fmg.py \
    ${mgdir} \
    ${indir}/Afribiota__insertcounts.lengthnorm.profile \
    > ${logdir}/Afribiota__insertcounts.lengthnorm.profile.cellab.log