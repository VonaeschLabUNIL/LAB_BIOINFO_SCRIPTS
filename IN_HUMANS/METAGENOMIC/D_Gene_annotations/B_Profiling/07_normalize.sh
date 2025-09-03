#!/bin/bash
#SBATCH --job-name=normfmg
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=100M
#SBATCH --time=00:10:00

# Load necessary modules - adapt
module load python/3.12.1

## Variables
indir=/scratch/<USERS>/<Project_scratch>/catalogue/profiles/merged
mgdir=/scratch/<USERS>/<Project_scratch>/catalogue/fmg
logdir=/scratch/<USERS>/<Project_scratch>/catalogue/log
scriptdir=/users/<USERS>/<Project_scratch>/scripts/D_gene_catalog

python ${scriptdir}/normalise_by_motus_v3.fmg.py \
    ${mgdir} \
    ${indir}/Project_name__insertcounts.lengthnorm.profile \
    > ${logdir}/Project_name__insertcounts.lengthnorm.profile.cellab.log
