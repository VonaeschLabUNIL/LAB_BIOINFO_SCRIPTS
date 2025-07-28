#!/bin/bash

####--------------------------------------
##SLURM options
####--------------------------------------
#SBATCH --partition cpu
#SBATCH --job-name assembly_QC
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 8G
#SBATCH --time 04:00:00
#SBATCH --output /users/syersin2/test_dir/std_output/%x_%j.out
#SBATCH --error /users/syersin2/test_dir/std_output/%x_%j.err
#SBATCH --array=1-4

##Variables
pacbio_workdir=/users/syersin2/test_dir
pacbio_indir=/users/syersin2/test_dir/output_pacbio/polishing
pacbio_outdir=/users/syersin2/test_dir/output_pacbio/quast
cd /users/syersin2/test_dir/output_pacbio/filtered_reads/
sample_name=$(ls *.fastq | sed -n ${SLURM_ARRAY_TASK_ID}p)
cd ${pacbio_workdir}
reference_fasta=/users/syersin2/test_dir/output_pacbio/assemblies/${sample_name}.gz/assembly.fasta
threads=8

####--------------------------------------
##modules
module load gcc/10.4.0
module load mummer/3.23

###===========================
##Quast
echo -e "-------1. First run Quast"
###===========================

rm -r ${pacbio_workdir}/output_pacbio/quast/
mkdir -p ${pacbio_workdir}/output_pacbio/quast/${sample_name}

python3.6 /software/UHTS/Quality_control/quast/4.6.0/bin/quast.py \
      -l "FlyeAssembly,first_PacBio_racon" \
      -R ${pacbio_indir}/${sample_name}/02_second_Racon_graphmap/assembly/${sample_name}_second_Racon_Assembly.fasta \
      ${reference_fasta} \
      ${pacbio_indir}/${sample_name}/01_first_Racon_graphmap/assembly/${sample_name}_first_Racon_Assembly.fasta \
      -o  ${pacbio_outdir}/${sample_name}/
# Using Quest: python3.6 /software/UHTS/Quality_control/quast/4.6.0/bin/quast.py -h
# -l labels, names of assemblies to use in report, comma-separated. If contain spaces, use quotes
# -R reference for Quast, the genome sequence after the last polishing step. In our case, the second racon assembly (second round polishing)
echo -e "Job Done"