#!/bin/sh
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data" 

for subject in $(cat "${data_directory}/code/subjects.txt")
do 

echo "----------------- Whole-brain fibre tractography on FOD template -----------------"	

	cd "${data_directory}/derivatives/MRtrix3/template"
	
	tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 "wmfod_template.mif" -seed_image "template_mask.mif" -select 20000000 -cutoff 0.06 tracks_20_million.tck -force
	
echo "----------------- Reduce Biases in Tractogram Desnisites -----------------"
	
	tcksift tracks_20_million.tck "wmfod_template.mif" tracks_2_million_sift.tck -term_number 2000000 -force
	
done 

#took two weeks to run
