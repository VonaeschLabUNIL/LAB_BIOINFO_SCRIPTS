#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name bowtie2
#SBATCH --error /scratch/syersin2/std_output/%x_%j.err
#SBATCH --output /scratch/syersin2/std_output/%x_%j.out
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user simon.yersin@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 50G
#SBATCH --time 02:00:00
#SBATCH --array=1-346

module load gcc/11.4.0
module load bowtie2/2.5.1

indir=/scratch/syersin2/cleaned_reads
outdir=/scratch/syersin2/bw_cleaned_reads
indexdir=/scratch/syersin2/index
logdir=/scratch/syersin2/log

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
