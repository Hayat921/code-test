#!/bin/sh
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data" 

mkdir -p "${data_directory}/derivatives/MRtrix3/masks"
mkdir -p "${data_directory}/derivatives/MRtrix3/fods"
mkdir -p "${data_directory}/derivatives/MRtrix3/fd"	
mkdir -p "${data_directory}/derivatives/MRtrix3/fixels"



for subject in $(cat "${data_directory}/code/subjects.txt")
do 
 	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_mask_in_template_space.mif" "${data_directory}/derivatives/MRtrix3/masks/"
done

mrmath ${data_directory}/derivatives/MRtrix3/masks/*_mask_in_template_space.mif min "${data_directory}/derivatives/MRtrix3/template/template_mask.mif" 

echo "----------------- FOD to FD -----------------"


	fod2fixel -mask "${data_directory}/derivatives/MRtrix3/template/template_mask.mif" -fmls_peak_value 0.06 "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" "${data_directory}/derivatives/MRtrix3/template/fixel_mask"
	

	
for subject in $(cat "${data_directory}/code/subjects.txt")
do

	mrtransform  "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_norm.mif" -warp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" -reorient_fod no "${data_directory}/derivatives/MRtrix3/fods/${subject}_fod_in_template_space_NOT_REORIENTED.mif"
	
	fod2fixel -mask "${data_directory}/derivatives/MRtrix3/template/template_mask.mif" "${data_directory}/derivatives/MRtrix3/fods/${subject}_fod_in_template_space_NOT_REORIENTED.mif" "${data_directory}/derivatives/MRtrix3/fixels/${subject}_fixel_in_template_space_NOT_REORIENTED" -afd fd.mif
	
	fixelreorient "${data_directory}/derivatives/MRtrix3/fixels/${subject}_fixel_in_template_space_NOT_REORIENTED" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" "${data_directory}/derivatives/MRtrix3/fixels/${subject}_fixel_in_template_space_reoriented"
	
done 
	
echo "----------------- Starting to assign subject fixel to template fixels -----------------"

for subject in $(cat "${data_directory}/code/subjects.txt")
do

	fixelcorrespondence "${data_directory}/derivatives/MRtrix3/fixels/${subject}_fixel_in_template_space_reoriented/fd.mif" "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/derivatives/MRtrix3/template/fd" "${subject}_fd.mif" 
	
done 

echo "----------------- Computing FC  -----------------"

for subject in $(cat "${data_directory}/code/subjects.txt")
do

	warp2metric "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" -fc "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/derivatives/MRtrix3/template/fc" "${subject}_fc.mif" 
done 

	mkdir "${data_directory}/derivatives/MRtrix3/template/log_fc"
	
	cp "${data_directory}/derivatives/MRtrix3/template/fc/index.mif" "${data_directory}/derivatives/MRtrix3/template/fc/directions.mif" "${data_directory}/derivatives/MRtrix3/template/log_fc"
	
for subject in $(cat "${data_directory}/code/subjects.txt")

do
	
	mrcalc "${data_directory}/derivatives/MRtrix3/template/fc/${subject}_fc.mif" -log "${data_directory}/derivatives/MRtrix3/template/log_fc/${subject}_fc.mif"
	
done 
	
echo "----------------- Computing FDC -----------------"

mkdir "${data_directory}/derivatives/MRtrix3/template/fdc"
	
	cp "${data_directory}/derivatives/MRtrix3/template/fc/index.mif" "${data_directory}/derivatives/MRtrix3/template/fdc" 
	cp "${data_directory}/derivatives/MRtrix3/template/fc/directions.mif" "${data_directory}/derivatives/MRtrix3/template/fdc"
	
for subject in $(cat "${data_directory}/code/subjects.txt")

do
	
	mrcalc "${data_directory}/derivatives/MRtrix3/template/fd/${subject}_fd.mif" "${data_directory}/derivatives/MRtrix3/template/fc/${subject}_fc.mif" -mult "${data_directory}/derivatives/MRtrix3/template/fdc/${subject}_fdc.mif"
	
done 		
	
echo "----------------- Whole-brain fibre tractography on FOD template -----------------"	

	cd "${data_directory}/derivatives/MRtrix3/template"
	
	tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 "wmfod_template.mif" -seed_image "template_mask.mif" -select 20000000 -cutoff 0.06 tracks_20_million.tck
	
echo "----------------- Reduce Biases in Tractogram Desnisites -----------------"
	
	tcksift tracks_20_million.tck "wmfod_template.mif" tracks_2_million_sift.tck -term_number 2000000



	
	
	
	
	
	
	
	
	
	
	
	
 


	
	










