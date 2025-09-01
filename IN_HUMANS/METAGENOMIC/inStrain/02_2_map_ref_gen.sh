#!/bin/bash

#SBATCH --job-name map_reads
#SBATCH --output /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USERS>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 20G
#SBATCH --time 02:00:00
#SBATCH --array=1-XX

# Script to map reads onto index using bowtie2

#Load modules - adapt
module load gcc/11.4.0
module load bowtie2/2.5.1
module load samtools/1.17

# Variables
indir=/scratch/<USERS>/<Project_scratch>/reads
outdir=/scratch/<USERS>/<Project_scratch>/mapping_output
index=/scratch/<USERS>/<Project_scratch>/tables/genomes_db/bt2_index
tmp=/scratch/<USERS>/<Project_scratch>/tmp

cd ${indir}
# Define the array variables
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

# Create new directory for each sample
mkdir -p ${outdir}/${sample_name}

echo “###############################################”
echo ${sample_name} “Start time: $(date -u)”
echo “##############################################”

bowtie2 --very-sensitive-local \
	--threads 16 \
	--al-conc-gz ${outdir}/${sample_name}/${sample_name}_bowtie2_R%_001.fastq.gz \
	-x ${index}/allGenomes_index \
	-1 ${indir}/${sample_name}/${sample_name}_FASTP_BOWTIE2_R1_001.fastq.gz -2 ${indir}/${sample_name}/${sample_name}_FASTP_BOWTIE2_R2_001.fastq.gz \
	-S ${outdir}/${sample_name}/${sample_name}_allGenomesMapped.sam \
	2> ${outdir}/${sample_name}/${sample_name}_bowtie2.log

echo “##############################################”
echo ${sample_name} “Bowtie Finishing time and Samtool starting time: $(date -u) ”
echo “##############################################”

# Convert .sam files obtained after alignments to .bam file and sort it 
samtools view -F 4 -bh ${outdir}/${sample_name}/${sample_name}_allGenomesMapped.sam \
    | samtools sort -O bam -@ 4 -m 4G -T ${tmp} \
    -o ${outdir}/${sample_name}/${sample_name}_sorted_allGenomesMapped.bam

# Index the sorted BAM file
samtools index ${outdir}/${sample_name}/${sample_name}_sorted_allGenomesMapped.bam

rm ${outdir}/${sample_name}/${sample_name}_allGenomesMapped.sam

echo “##############################################”
echo ${sample_name} “Finishing time: $(date -u)”
echo “##############################################”
