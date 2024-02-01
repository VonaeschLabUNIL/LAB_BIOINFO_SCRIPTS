#Script to merge forward and reverse reads from MicroSynth sequencing results and make a high-throuput blast and consolidation of results




#RENAMING FOR BETTER CONVENIENCE IN FUTURE COMMANDS

rename 's/-R_1492r.fasta/_R1_001.fasta/g' *.fasta

rename 's/-F_27f.fasta/_R2_001.fasta/g' *.fasta


# CONVERT FASTA TO FAKE FASTQ FOR FUTURE STEP USING seqtk and generating fake quality scores:

mkdir FAKE_FASTQ

for prefix in $(ls *_001.fasta | sed -E 's/[.]fasta//' | uniq)
do 
seqtk seq -F '#' "${prefix}.fasta" > FAKE_FASTQ/${prefix}.fastq
done


#MERGING READS

#Merging reads with FLASH

#https://github.com/genome-vendor/FLASH


source ~/anaconda3/etc/profile.d/conda.sh
conda activate FLASH


mkdir MERGED_READS
mkdir MERGED_READS/EXTENDED


for prefix in $(ls *.fastq | sed -E 's/_R[12]_001[.]fastq//' | uniq)
do
flash --max-overlap 1500 -o "${prefix}"_MERGED -d ./MERGED_READS "${prefix}_R1_001.fastq" "${prefix}_R2_001.fastq"
done

mv MERGED_READS/*.extendedFrags.fastq MERGED_READS/EXTENDED/


cd MERGED_READS/EXTENDED

mkdir CONVERTED_TO_FASTA

for file in *.fastq
do
echo "Converting file" "${file}" "to fasta" 

seqtk seq -A ${file} > ./CONVERTED_TO_FASTA/${file}.fasta

done
 
rename 's/.extendedFrags.fastq//g' CONVERTED_TO_FASTA/*.fasta

conda deactivate


#USING THE NEW CURATED 16s DB FROM NCBI DOWNLAODED AT AND UNZIPPED

#https://ftp.ncbi.nlm.nih.gov/blast/db/
#16S_ribosomal_RNA.tar.gz

cd CONVERTED_TO_FASTA

for file in *.fasta
do

echo ${file}

db_folder="16S_ribosomal_RNA"
db="16S_ribosomal_RNA"

echo "Doing a blastn using" "${file}" "as query and" "${db}" "as blast database"
blastn -query ${file} -num_threads 10 -db ${db_folder}/${db} -perc_identity 90 -max_target_seqs 10 -outfmt '7 qseqid sseqid pident evalue bitscore length qcovhsp mismatch gapopen qstart qend sstart send sgi sacc stitle' -out ./${file}_VS_${db}_90_PERC.tab

echo "Filtering the file using grep to get only the results for" "${file}" "and" "${db}"

#Clean unwanted lines
grep -m 1 '# Fields' ./${file}_VS_${db}_90_PERC.tab  > FILETRED_${file}_VS_${db}_90_PERC.tab
grep -v '#' ${file}_VS_${db}_90_PERC.tab  >> FILETRED_${file}_VS_${db}_90_PERC.tab

#Replace comma by TABs, and further clean
sed -i "" "s/, /\t/g" FILETRED_${file}_VS_${db}_90_PERC.tab
sed -i "" "s/# Fields: //g" FILETRED_${file}_VS_${db}_90_PERC.tab

rm ${file}_VS_${db}_90_PERC.tab

done

cat *.tab > GATHERED_RESULTS.tab




