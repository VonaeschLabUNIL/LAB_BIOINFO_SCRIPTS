mkdir /media/wslnx/18TERA/MARGAUX/Viterbi_Gut/Stool_samples/20231013_Data_release/X204SC23050192-Z01-F004_correct/01.RawData/INTEGRITY



for folder in $(ls -d */ | cut -d "/" -f 1 | uniq)
do
	#echo $folder 
	cd ${folder}
	#ls
	md5sum -c *MD5*.txt > /media/wslnx/18TERA/MARGAUX/Viterbi_Gut/Stool_samples/20231013_Data_release/X204SC23050192-Z01-F004_correct/01.RawData/INTEGRITY/INTEGRITY_checks_${folder}.txt
	#md5sum -c *MD5*.txt >> /media/wslnx/18TERA/MARGAUX/Viterbi_Gut/Stool_samples/20231013_Data_release/X204SC23050192-Z01-F004_correct/01.RawData/INTEGRITY/INTEGRITY_checks_ALL.txt
	cd ..
done


#cd ../INTEGRITY

#cat *.txt > CONCAT_INTEGRITY.csv


