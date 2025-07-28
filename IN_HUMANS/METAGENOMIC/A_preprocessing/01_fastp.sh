#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name fastp
#SBATCH --error /scratch/syersin2/std_output/%x_%j.err
#SBATCH --output /scratch/syersin2/std_output/%x_%j.out
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 8G
#SBATCH --time 00:20:00
#SBATCH --array=1-346

module load gcc/11.4.0
module load fastp/0.23.4

indir=/scratch/syersin2/RawData
outdir=/scratch/syersin2/cleaned_reads
reportdir=/scratch/syersin2/REPORTS_CLEANED_READS

cd ${indir}
sample=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

mkdir -p ${outdir}/${sample}
mkdir -p ${reportdir}

echo "###############################################"
echo $id "Start time: $(date -u)"
echo "performing cleaning on files :" "${sample}_R1_001.fastq.gz" "${sample}_R2_001.fastq.gz"
echo "##############################################"

fastp -i ${indir}/${sample}/${sample}_R1_001.fastq.gz -I ${indir}/${sample}/${sample}_R2_001.fastq.gz \
	-o ${outdir}/${sample}/${sample}_FASTP_R1_001.fastq.gz  -O ${outdir}/${sample}/${sample}_FASTP_R2_001.fastq.gz \
	--report_title ${sample}_fastp_report \
	--thread 16 \
	-j ${reportdir}/${sample}_fastp.json \
	-h ${reportdir}/${sample}_fastp.html

echo "##############################################"
echo $id "Finishing time: $(date -u)"
echo "##############################################"
