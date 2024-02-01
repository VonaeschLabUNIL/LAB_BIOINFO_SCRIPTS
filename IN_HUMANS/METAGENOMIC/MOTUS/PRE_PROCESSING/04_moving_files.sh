cd /media/wslnx/18TERA/MARGAUX/Viterbi_Gut/Stool_samples/20231013_Data_release/RawData/Children_1w
for folder in $(ls -d */ | cut -d "/" -f 1 | uniq)
do 
	cd ${folder}
	#ls *fastq.gz
	mv *fastq.gz /media/wslnx/18TERA/MARGAUX/Viterbi_Gut/Stool_samples/20231013_Data_release/RawData
	cd ..
done

