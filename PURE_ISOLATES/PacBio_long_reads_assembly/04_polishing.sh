#!/bin/bash

###------------------
##SLURM options
###------------------
#SBATCH --partition cpu
#SBATCH --job-name polishing
#SBATCH --output /users/syersin2/test_dir/std_output/%x_%j.out
#SBATCH --error /users/syersin2/test_dir/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 1
#SBATCH --mem 16G
#SBATCH --time 03:00:00
#SBATCH --array=1-4

##Variables
pacbio_workdir=/users/syersin2/test_dir
pacbio_indir=/users/syersin2/test_dir/output_pacbio/filtered_reads/
pacbio_outdir=/users/syersin2/test_dir/output_pacbio/polishing/
cd ${pacbio_indir}
pacbio_reads=$(ls *.fastq | sed -n ${SLURM_ARRAY_TASK_ID}p)
cd ${pacbio_workdir}
reference_fasta=/users/syersin2/test_dir/output_pacbio/assemblies/${pacbio_reads}.gz/assembly.fasta

##LOAD MODULE
module load gcc/10.4.0
module load graphmap/0.3.0 #A highly sensitive and accurate mapper for long, error-prone reads
module load racon/1.5.0 #Ultrafast consensus module for raw de novo genome assembly of long uncorrected reads.

###===========================
##Priming the variables used and starting the for-loop
echo -e "-------0. Priming the variables used and starting the for-loop"
###===========================

overall_polishing_counter=1
rm -r ${pacbio_workdir}/output_pacbio/polishing/
mkdir -p ${pacbio_workdir}/output_pacbio/polishing/${pacbio_reads}

for polishing_counter in $(echo "first second")
do
echo -e "----"${polishing_counter}" round of Racon polishing"

###===========================
##graphmap mapping
echo -e "-------1. First we map with graphmap"
###===========================

##only run this line if you do not have a fastq file yet.

mkdir -p ${pacbio_outdir}/${pacbio_reads}/0${overall_polishing_counter}_${polishing_counter}_Racon_graphmap/{Graphmap_PacBio,assembly}

graphmap align --rebuild-index \
        --circular  \
        -r ${reference_fasta} \
        -d ${pacbio_indir}/${pacbio_reads} \
        -o ${pacbio_outdir}/${pacbio_reads}/0${overall_polishing_counter}_${polishing_counter}_Racon_graphmap/Graphmap_PacBio/${polishing_counter}_Racon_PacBio2FinalAssembly_sorted.sam

###===========================
##racon polishing
echo -e "-------2. Second polish with Racon"
###===========================

racon ${pacbio_indir}/${pacbio_reads}  \
${pacbio_outdir}/${pacbio_reads}/0${overall_polishing_counter}_${polishing_counter}_Racon_graphmap/Graphmap_PacBio/${polishing_counter}_Racon_PacBio2FinalAssembly_sorted.sam  \
${reference_fasta} \
>  ${pacbio_outdir}/${pacbio_reads}/0${overall_polishing_counter}_${polishing_counter}_Racon_graphmap/assembly/${pacbio_reads}_${polishing_counter}_Racon_Assembly.fasta

###===========================
##reset the parameters
echo -e "-------3. Resetting the parameters"
###===========================

{reference_fasta}=$(echo $pacbio_outdir/${pacbio_reads}/0${overall_polishing_counter}_${polishing_counter}_Racon_graphmap/assembly/${pacbio_reads}_${polishing_counter}_Racon_Assembly.fasta)
overall_polishing_counter=$((overall_polishing_counter+1))

done #polishing round

echo -e "JOB DONE"