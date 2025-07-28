#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name fastp
#SBATCH --output /scratch/syersin2/Satellite_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Satellite_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 8G
#SBATCH --time 00:20:00
#SBATCH --array=1-9

#Modules
module load gcc/11.4.0
module load fastp/0.23.4

#Variables
indir=/scratch/syersin2/Satellite_scratch/Isolates/data
outdir=/scratch/syersin2/Satellite_scratch/Isolates/cleaned_reads
reportdir=/scratch/syersin2/Satellite_scratch/Isolates/REPORTS_CLEANED_READS

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