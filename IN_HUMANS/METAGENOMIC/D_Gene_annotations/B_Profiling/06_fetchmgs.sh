#!/bin/bash
#SBATCH --job-name=fetchMG
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=4G
#SBATCH --time=02:00:00

# Load necessary modules - adapt
module load gcc/12.3.0
module load perl/5.38.0

## Variables
scriptdir=/work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/FetchMGs/fetchMGs.pl
indir=/scratch/<USERS>/<Project_scratch>/catalogue/derepcat
outdir=/scratch/<USERS>/<Project_scratch>/catalogue/fmg

rm -r ${outdir}

${scriptdir}/fetchMGs.pl -m extraction ${indir}/Gene_catalog_derep.faa \
    -d ${indir}/Gene_catalog_derep.fna \
    -i \
    -t 10 \
    -o ${outdir}



