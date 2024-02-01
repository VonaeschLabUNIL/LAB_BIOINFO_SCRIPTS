
# mOTUs profiler
# Version 3.1.0

# options: 
# -f forward fastq -r reverse fastq
# -o output file
# -u print full name of species
# -c print results as counts instead of relative abundance
# -p print NCBI taxonomy identifier
# -q print full rank taxonomy
# -A print all taxonomy levels together (kingdom to mOTUs, override -k)
# -k taxonomic level (kingdom, phylum, class, order, family, genus, mOTU)
# -t threads


mkdir MOTUS_PROFILE

for prefix in $(ls *.fastq.gz | sed -E 's/_R[12]_001[.]fastq.gz//' | uniq)
  do
    echo "Comptage de reads de " "${prefix}"
    #motus profile -s ${prefix}_R1_001.fastq.gz -t 36 -o MOTUS_ANALYSIS/MOTUS_${level}_READS/${prefix}_${level}_READS.motus -n ${prefix}_READS -k ${level} -p -q -c 
    motus profile -f ${prefix}_R1_001.fastq.gz -r ${prefix}_R2_001.fastq.gz -t 36 -o MOTUS_PROFILE/motus_${prefix}.tsv -n ${prefix}_motus_count -k mOTU -c -p -q
    echo "${prefix}" "done"
done

   
