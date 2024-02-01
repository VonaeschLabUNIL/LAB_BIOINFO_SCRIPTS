for folder in $(ls -d */ | cut -d "/" -f 1 | uniq)
do
	cd ${folder}
	cat *_1.fq.gz > ${folder}_R1_001.fastq.gz
	cat *_2.fq.gz > ${folder}_R2_001.fastq.gz
	cd ..
done

