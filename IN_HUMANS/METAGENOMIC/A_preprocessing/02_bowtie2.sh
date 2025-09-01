#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name bowtie2
#SBATCH --error /scratch/*USERS*/std_output/%x_%j.err
#SBATCH --output /scratch/*USERS*/std_output/%x_%j.out
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 50G
#SBATCH --time 02:00:00
#SBATCH --array=1-XX

module load gcc/11.4.0
module load bowtie2/2.5.1

indir=/scratch/*USERS*/cleaned_reads
outdir=/scratch/*USERS*/bw_cleaned_reads
indexdir=/scratch/*USERS*/index
logdir=/scratch/*USERS*/log

cd ${indir}
sample=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

echo "###############################################"
echo $id "Start time: $(date -u)"
echo "##############################################"

bowtie2 --very-sensitive-local --threads 16 \
	--un-conc-gz ${outdir}/${sample}_bowtie2_R%_001.fastq.gz \
	-x ${indexdir}/GRCh38_latest_genomic.INDEX \
	-1 ${indir}/${sample}/${sample}_FASTP_R1_001.fastq.gz \
	-2 ${indir}/${sample}/${sample}_FASTP_R2_001.fastq.gz \
	-S ${outdir}/${sample}_GRCh38_latest_genomic.sam \
	2>${logdir}/${sample}_bowtie2.log

rm ${outdir}/${sample}_GRCh38_latest_genomic.sam

echo "##############################################"
echo $id "Finishing time: $(date -u)"
echo "##############################################"
