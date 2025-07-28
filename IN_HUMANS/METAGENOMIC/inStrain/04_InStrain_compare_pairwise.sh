#!/bin/bash

#SBATCH --job-name 05_InStrain_compare_pairwise
#SBATCH --output /scratch/mcreze/InStrain_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/mcreze/InStrain_scratch/std_output/%x_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user margaux.creze@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 4
#SBATCH --mem 5G
#SBATCH --time 00:05:00
#SBATCH --array 1-470

#Load modules
module load gcc/11.4.0
module load miniconda3/22.11.1

#Activate the Instrain environment
eval "$(/dcsrsoft/spack/external/micromamba/1.4.9/bin/micromamba-linux-64 shell hook --shell bash --root-prefix /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/mcreze/MAMBA/mamba_root 2> /dev/null)"
micromamba activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/mcreze/INSTRAIN/instrain

# Define directories
profile_dir=/scratch/mcreze/InStrain_scratch/instrain_output/instrain_profile
filedir=/scratch/mcreze/InStrain_scratch/Tables
outdir=/scratch/mcreze/InStrain_scratch/instrain_output/instrain_compare

mkdir -p ${outdir}

# Get the pair for this task
pair=$(sed -n "${SLURM_ARRAY_TASK_ID}p" pairs.txt)

# Extract mother and child sample names
mother=$(echo $pair | awk '{print $1}')
child=$(echo $pair | awk '{print $2}')

# Extract the pair number (e.g., "001" from C1WST001 and MPST001)
pair_number=$(echo $mother | sed -E 's/^[A-Za-z]+([0-9]+)_inStrainOut$/\1/')

# Define the output directory as VG + pair_number
output_dir=${outdir}/VG${pair_number}

echo “###############################################”
echo "Processing pair: $mother and $child"
echo “###############################################”
echo $id “Start time: $(date -u)”
echo “##############################################”

# Run inStrain compare for the pair
inStrain compare -ani 0.99999 -cov 0.5 \
    -i ${profile_dir}/${mother} ${profile_dir}/${child} \
    -s ${filedir}/genomes.stb \
    -p 24 \
    -o ${output_dir} \
    --database_mode

echo “##############################################”
echo $id “Finishing time: $(date -u) ”
echo “#############################################”
