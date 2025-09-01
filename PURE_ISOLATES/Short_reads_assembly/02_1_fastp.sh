#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name fastp
#SBATCH --output /scratch/<USER>/<Project_scratch>/std_output/%x_%j.out
#SBATCH --error /scratch/<USER>/<Project_scratch>/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 8G
#SBATCH --time 00:20:00
#SBATCH --array=1-XXX

# Modules - adapt
module load gcc/11.4.0
module load fastp/0.23.4

#Variables
indir=/scratch/<USER>/<Project_scratch>/data
outdir=/scratch/<USER>/<Project_scratch>/cleaned_reads
reportdir=/scratch/<USER>/<Project_scratch>/REPORTS_CLEANED_READS

# Array variables
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
