#!/bin/bash
#SBATCH --job-name=fetchMG
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --mem=4G
#SBATCH --time=02:00:00

# Load necessary modules
module load gcc/12.3.0
module load perl/5.38.0

## Variables
scriptdir=/work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/FetchMGs/fetchMGs.pl
indir=/scratch/syersin2/Afribiota_scratch/catalogue/derepcat
outdir=/scratch/syersin2/Afribiota_scratch/catalogue/fmg

rm -r ${outdir}

${scriptdir}/fetchMGs.pl -m extraction ${indir}/Afribiota_gene_catalog_derep.faa \
    -d ${indir}/Afribiota_gene_catalog_derep.fna \
    -i \
    -t 10 \
    -o ${outdir}



