
##### Automation of alignment
# Building of genome index on which we want to align: necessary for Bowtie2
# Put the fasta file that will be used for bowtie index in ./CLEANED_READS

#ASSUMES ZIPPED FILES (.gz)

# Install bowtie2
# conda install -c bioconda bowtie2
# conda activate bowtie2 to activate the right environment

# Generate the index
for file in *.fna
do
	bowtie2-build --large-index --threads 10 $file $file.INDEX
done

#mkdir FASTQC_ANALYSIS

for index in *.fna
do
#Create directory for future file storage
mkdir ${index}.INDEX

	# Loop for alignment of each read PE files on each genome (index)
	for prefix in $(ls *.fastq.gz | sed -E 's/_R[12]_001[.]fastq.gz//' | uniq)
	do
	echo "performing alignment on files :" "${prefix}_R1_001.fastq.gz" "&" "${prefix}_R2_001.fastq.gz" "ON INDEX :" "${index}"
	bowtie2  --very-sensitive --un-conc-gz ./"${index}.INDEX/HOST_EXTRACTED_${prefix}_R%_001.fastq.gz" -p 34 -x $index.INDEX -1 "${prefix}_R1_001.fastq.gz" -2 "${prefix}_R2_001.fastq.gz" -S ./"${index}.INDEX"/"${prefix}_${index}.sam" 2>./"${index}.INDEX"/"${prefix}_${index}_BOWTIE2.log"
	rm ./"${index}.INDEX"/"${prefix}_${index}.sam"
	done
fastqc *.fastq.gz -o ./FASTQC_ANALYSIS
fastqc ./"${index}.INDEX"/*.fastq.gz -o ./FASTQC_ANALYSIS
done


multiqc ./FASTQC_ANALYSIS/* --ignore-symlinks --outdir ./FASTQC_ANALYSIS/MULTIQC_FILES --filename ALL_REPORTS_MULTIQC --fullnames --title ALL_REPORTS_MULTIQC

multiqc ./"${index}.INDEX"/* --ignore-symlinks --outdir ./FASTQC_ANALYSIS/MULTIQC_MAPPING_INFOS --filename MULTIQC_MAPPING_INFOS --fullnames --title MULTIQC_MAPPING_INFOS







