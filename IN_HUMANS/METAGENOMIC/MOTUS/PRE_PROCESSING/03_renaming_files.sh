
for myfile in *fq.gz; 
do
    target=$(echo $myfile|sed -E 's/_.{13}\-1A_.{9}_L[1234]//g')
    #echo $target
    mv "$myfile" "$target"
done

for file in *_1.fq.gz; do
    echo "changing filname of" "${file}"
    mv "$file" "${file/_1.fq.gz/_R1_001.fastq.gz}" 
done

for file in *_2.fq.gz; do
    echo "changing filname of" "${file}"
    mv "$file" "${file/_2.fq.gz/_R2_001.fastq.gz}" 
done