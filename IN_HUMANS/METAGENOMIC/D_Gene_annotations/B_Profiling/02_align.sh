#!/bin/bash
#SBATCH --job-name=bwa_align
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=16G
#SBATCH --time=06:00:00
#SBATCH --array=2-57

# Load necessary modules
module load gcc/12.3.0
module load bwa/0.7.17
module load samtools/1.19.2

## Variables
catdir=/scratch/syersin2/Afribiota_scratch/catalogue/derepcat
indir=/scratch/syersin2/Afribiota_scratch/bw_cleaned_reads
outdir=/scratch/syersin2/Afribiota_scratch/catalogue/alignment

## Array variables
sample=$(ls ${indir} | sed -n ${SLURM_ARRAY_TASK_ID}p)

mkdir -p ${outdir}/${sample}

## Align reads to gene catalog
echo "Running BWA MEM for forward : " ${sample}
bwa mem -a -t 8 ${catdir}/Afribiota_gene_catalog_derep.fna ${indir}/${sample}/${sample}_bowtie2_R1_001.fastq.gz \
    | samtools view -F 4 -bh - > ${outdir}/${sample}/${sample}_r1.bam

echo "Running BWA MEM for reverse : " ${sample}
bwa mem -a -t 8 ${catdir}/Afribiota_gene_catalog_derep.fna ${indir}/${sample}/${sample}_bowtie2_R2_001.fastq.gz \
    | samtools view -F 4 -bh - > ${outdir}/${sample}/${sample}_r2.bam

echo "Alignment complete"

## -a output all alignment for SE or unpaired PE
## -t threads
