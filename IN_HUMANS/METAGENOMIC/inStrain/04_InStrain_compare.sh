#!/bin/bash

#SBATCH --job-name InStrain_compare
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 24
#SBATCH --mem 8G
#SBATCH --time 04:00:00

# Run instrain compare

#Load modules - adapt
module load gcc/11.4.0
module load miniconda3/22.11.1

#Activate the Instrain environment
eval "$(/dcsrsoft/spack/external/micromamba/1.4.9/bin/micromamba-linux-64 shell hook --shell bash --root-prefix /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/mcreze/MAMBA/mamba_root 2> /dev/null)"
micromamba activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/mcreze/INSTRAIN/instrain

# Define directories
profile_dir=/scratch/<USERS>/<Project_scratch>/instrain/instrain_profile
filedir=/scratch/<USERS>/<Project_scratch>/tables
outdir=/scratch/<USERS>/<Project_scratch>/instrain/instrain_compare

echo “###############################################”
echo $id “Start time: $(date -u)”
echo “##############################################”

inStrain compare -ani 0.99999 -cov 0.5 \
    -i ${profile_dir}/*_inStrainOut \
    -s ${filedir}/genomes.stb \
    -p 24 \
    -o ${outdir} \
    --database_mode

echo “##############################################”
echo $id “Finishing time: $(date -u) ”
echo “##############################################”
