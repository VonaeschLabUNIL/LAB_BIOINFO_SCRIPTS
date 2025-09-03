#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name groot
#SBATCH --output /scratch/amuhumme/MV_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/amuhumme/MV_scratch/std_output/%x_%j.err
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 4G
#SBATCH --time 01:00:00
#SBATCH --array=1-4

# Module
module load gcc/12.3.0
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/GROOT/groot
# Groot directory includes: bbmap and biopython

# Variables
datadir=/scratch/amuhumme/MV_scratch/pastobiome_scratch
filt_reads=/scratch/amuhumme/MV_scratch/filter
outdir=/scratch/amuhumme/MV_scratch/groot_out
index_dir=/work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/GROOT/databases/groot-db.90.index
pydir=/scratch/amuhumme/MV_scratch

## Array variables
cd ${datadir}
sample_name=$(ls | sed -n ${SLURM_ARRAY_TASK_ID}p)

# First we filter reads under 31 bases of lenght using bbmap code: reformat.sh
rm -r ${filt_reads}/${sample_name}
mkdir -p ${filt_reads}/${sample_name}

reformat.sh in1=${datadir}/${sample_name}/${sample_name}_bowtie2_R1_001.fastq.gz \
    in2=${datadir}/${sample_name}/${sample_name}_bowtie2_R2_001.fastq.gz \
    out1=${filt_reads}/${sample_name}/${sample_name}_reformat_R1_001.fastq.gz \
    out2=${filt_reads}/${sample_name}/${sample_name}_reformat_R2_001.fastq.gz \
    minLength=31

# Then we align the reads to the indexed database of groot 
rm -r ${outdir}/${sample_name}
mkdir -p ${outdir}/${sample_name}

groot align -p 8 \
    -i ${index_dir} \
    -g ${outdir}/${sample_name} \
    -t 0.95 \
    -f ${filt_reads}/${sample_name}/${sample_name}_reformat_R1_001.fastq.gz,${filt_reads}/${sample_name}/${sample_name}_reformat_R2_001.fastq.gz \
    --log ${outdir}/${sample_name}/${sample_name}.groot.log | groot report -p 8 -c 0.95 --log ${outdir}/${sample_name}/${sample_name}.groot.log > ${outdir}/${sample_name}/${sample_name}.report

# report:  This will report gene, read count, gene length, coverage cigar to STDOUT as tab separated values

python ${pydir}/parse_groot-report.py ${pydir}/res_classes.tsv ${outdir}/${sample_name}/${sample_name}.report