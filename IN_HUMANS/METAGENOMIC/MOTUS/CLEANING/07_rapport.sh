mkdir FASTQC_ANALYSIS
for index in *.fna
do
	fastqc *.fastq.gz -o ./FASTQC_ANALYSIS
	fastqc ./"${index}.INDEX"/*.fastq.gz -o ./FASTQC_ANALYSIS

done


multiqc ./FASTQC_ANALYSIS/* --ignore-symlinks --outdir ./FASTQC_ANALYSIS/MULTIQC_FILES --filename ALL_REPORTS_MULTIQC --fullnames --title ALL_REPORTS_MULTIQC
multiqc ./"${index}.INDEX"/* --ignore-symlinks --outdir ./FASTQC_ANALYSIS/MULTIQC_MAPPING_INFOS --filename MULTIQC_MAPPING_INFOS --fullnames --title MULTIQC_MAPPING_INFOS