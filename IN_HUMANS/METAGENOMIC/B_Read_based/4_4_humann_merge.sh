#!/bin/bash

#SBATCH --partition cpu
#SBATCH --job-name humann_merge
#SBATCH --output /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.out
#SBATCH --error /scratch/syersin2/Pastobiome_scratch/std_output/%x_%j.err
#SBATCH --mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --mail-user simon.yersin@unil.ch
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 2
#SBATCH --mem 50G
#SBATCH --time 08:00:00

# Humann v.3.9

# Module
module load gcc/12.3.0
module load miniforge3/4.8.3-4-Linux-x86_64

# Activate conda environment
eval "$(conda shell.bash hook)"
conda activate /work/FAC/FBM/DMF/pvonaesc/vonasch_lab_general/syersin/HUMANN/humann

# Variables
humann_dir=/scratch/syersin2/Pastobiome_scratch/data/humann
outdir=/scratch/syersin2/Pastobiome_scratch/data/humann_join_tables
cd ${humann_dir}

# pathcoverage
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_pathcoverage.tsv \
    --file_name pathcoverage.tsv \
    -s

# pathabundance
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_pathabundance.tsv \
    --file_name pathabundance.tsv \
    -s
# pathabundance cpm
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_pathabundance_cpm.tsv \
    --file_name pathabundance_cpm.tsv \
    -s
# pathabundance relab
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_pathabundance_relab.tsv \
    --file_name pathabundance_relab.tsv \
    -s

# Uniref90
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_uniref90.tsv \
    --file_name genefamilies.tsv \
    -s
# Uniref90 cpm
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_uniref90_cpm.tsv \
    --file_name genefamilies_cpm.tsv \
    -s
# Uniref90 relab
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_uniref90_relab.tsv \
    --file_name genefamilies_relab.tsv \
    -s

# eggnog
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_eggnog.tsv \
    --file_name genefamilies_eggnog.tsv \
    -s
# eggnog cpm
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_eggnog_cpm.tsv \
    --file_name genefamilies_eggnog_cpm.tsv \
    -s
# eggnog relab
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_eggnog_relab.tsv \
    --file_name genefamilies_eggnog_relab.tsv \
    -s

# go
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_go.tsv \
    --file_name genefamilies_go.tsv \
    -s
# go cpm
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_go_cpm.tsv \
    --file_name genefamilies_go_cpm.tsv \
    -s
# go relab
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_go_relab.tsv \
    --file_name genefamilies_go_relab.tsv \
    -s

# ko
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_ko.tsv \
    --file_name genefamilies_ko.tsv \
    -s
# ko cpm
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_ko_cpm.tsv \
    --file_name genefamilies_ko_cpm.tsv \
    -s
# ko relab
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_ko_relab.tsv \
    --file_name genefamilies_ko_relab.tsv \
    -s

# level4ec
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_level4ec.tsv \
    --file_name genefamilies_level4ec.tsv \
    -s
# level4ec cpm
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_level4ec_cpm.tsv \
    --file_name genefamilies_level4ec_cpm.tsv \
    -s
# level4ec relab
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_level4ec_relab.tsv \
    --file_name genefamilies_level4ec_relab.tsv \
    -s

# pfam
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_pfam.tsv \
    --file_name genefamilies_pfam.tsv \
    -s
# pfam cpm
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_pfam_cpm.tsv \
    --file_name genefamilies_pfam_cpm.tsv \
    -s
# pfam relab
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_pfam_relab.tsv \
    --file_name genefamilies_pfam_relab.tsv \
    -s

# rxn
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_rxn.tsv \
    --file_name genefamilies_rxn.tsv \
    -s
# rxn cpm
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_rxn_cpm.tsv \
    --file_name genefamilies_rxn_cpm.tsv \
    -s
# rxn relab
humann_join_tables --input ${humann_dir} \
    --output ${outdir}/Pastobiome_humann_genefamilies_rxn_relab.tsv \
    --file_name genefamilies_rxn_relab.tsv \
    -s