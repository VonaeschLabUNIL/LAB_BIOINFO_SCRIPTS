# Automatisation du cleaning de reads avec fastp

# Table 3: Summary of 1S Plus tail trimming Recommendations
# 15 bases from END of Read1 15 bases from START of Read2

mkdir CLEANED_READS
mkdir REPORTS_CLEANED_READS


for prefix in $(ls *.fastq.gz | sed -E 's/_R[12]_001[.]fastq.gz//' | uniq)
do
echo "performing cleaning on files :" "${prefix}_R1_001.fastq.gz" "${prefix}_R2_001.fastq.gz"
fastp -i "${prefix}_R1_001.fastq.gz" -I "${prefix}_R2_001.fastq.gz" -o CLEANED_READS/"${prefix}_FASTP_R1_001.fastq.gz"  -O CLEANED_READS/"${prefix}_FASTP_R2_001.fastq.gz" --report_title "${prefix}_fastp_report" --thread 36 -j REPORTS_CLEANED_READS/"${prefix}_fastp".json -h REPORTS_CLEANED_READS/"${prefix}_fastp".html

done

multiqc ./REPORTS_CLEANED_READS/ --ignore-symlinks --outdir ./REPORTS_CLEANED_READS --filename MULTIQC_ALL_SAMPLE_REPORT --fullnames --title MULTIQC_ALL_SAMPLE_REPORT



#cd ./CLEANED_READS

