#!/bin/bash
#SBATCH --job-name=genecount
#SBATCH --output /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Afribiota_scratch/std_output/%x_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=100G
#SBATCH --time=03:00:00
#SBATCH --array=17

# Load necessary modules
module load gcc/12.3.0
module load seqkit/0.10.1
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/SushiCounter/counter

## Variables
indir=/scratch/syersin2/Afribiota_scratch/catalogue/alignment
outdir=/scratch/syersin2/Afribiota_scratch/catalogue/profiles
fqdir=/scratch/syersin2/Afribiota_scratch/bw_cleaned_reads 
logdir=/scratch/syersin2/Afribiota_scratch/catalogue/log

## Array variables
sample=$(ls ${indir} | sed -n ${SLURM_ARRAY_TASK_ID}p)
mkdir -p ${outdir}

# Compute base and insert count using seqkit:
echo "#####################################################"
echo $id " seqkit count started at: $(date -u)"
echo "#####################################################"
total_reads=$(seqkit stats -T ${fqdir}/${sample}/${sample}_bowtie2_R1_001.fastq.gz \
    ${fqdir}/${sample}/${sample}_bowtie2_R2_001.fastq.gz | awk 'NR>1 {print $4}' | paste -sd+ - | bc)
echo "total reads:  $total_reads"
total_bases=$(seqkit stats -T ${fqdir}/${sample}/${sample}_bowtie2_R1_001.fastq.gz \
    ${fqdir}/${sample}/${sample}_bowtie2_R2_001.fastq.gz | awk 'NR>1 {print $5}' | paste -sd+ - | bc)
echo "total bases: $total_bases"
insert_count=$(echo "$total_reads / 2" | bc)
echo "insert counts: $insert_count"
echo "#####################################################"
echo $id " seqkit count ended at: $(date -u)"
echo "#####################################################"
echo "#####################################################"
echo $id " gene count started at: $(date -u)"
echo "#####################################################"

sushicounter counter -pe ${indir}/${sample}/${sample}.a45.i95c080.bam \
    -o ${outdir}/${sample}.genecount.profile \
    -i 0.95 -c 0.8 -a 45 -m mem -ti ${insert_count} -tb ${total_bases} &> ${logdir}/${sample}.counter.log