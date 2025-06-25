#!/bin/sh
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 

mkdir -p "${data_directory}/derivatives/MRtrix3/masks"
mkdir -p "${data_directory}/derivatives/MRtrix3/fods"
mkdir -p "${data_directory}/derivatives/MRtrix3/fd"	
mkdir -p "${data_directory}/derivatives/MRtrix3/fixels"




for subject in $(cat "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI/code/sub_files.txt")
do
 	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_mask_in_template_space.mif" "${data_directory}/derivatives/MRtrix3/masks/"
done

mrmath ${data_directory}/derivatives/MRtrix3/masks/*_mask_in_template_space.mif min "${data_directory}/derivatives/MRtrix3/template/template_mask.mif" 

echo "----------------- FOD to FD -----------------"


	fod2fixel -mask "${data_directory}/derivatives/MRtrix3/template/template_mask.mif" -fmls_peak_value 0.06 "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" "${data_directory}/derivatives/MRtrix3/template/fixel_mask"
	

	
for subject in $(cat "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI/code/sub_files.txt")
do 


	mrtransform  "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_norm.mif" -warp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" -reorient_fod no "${data_directory}/derivatives/MRtrix3/fods/${subject}_fod_in_template_space_NOT_REORIENTED.mif"
	
	fod2fixel -mask "${data_directory}/derivatives/MRtrix3/template/template_mask.mif" "${data_directory}/derivatives/MRtrix3/fods/${subject}_fod_in_template_space_NOT_REORIENTED.mif" "${data_directory}/derivatives/MRtrix3/fixels/${subject}_fixel_in_template_space_NOT_REORIENTED" -afd fd.mif
	
	fixelreorient "${data_directory}/derivatives/MRtrix3/fixels/${subject}_fixel_in_template_space_NOT_REORIENTED" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" "${data_directory}/derivatives/MRtrix3/fixels/${subject}_fixel_in_template_space_reoriented"
	
done 
	
echo "----------------- Starting to assign subject fixel to template fixels -----------------"

for subject in $(cat "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI/code/sub_files.txt")
do 


	fixelcorrespondence "${data_directory}/derivatives/MRtrix3/fixels/${subject}_fixel_in_template_space_reoriented/fd.mif" "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/derivatives/MRtrix3/template/fd" "${subject}_fd.mif" 
	
done 

echo "----------------- Computing FC  -----------------"

for subject in $(cat "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI/code/sub_files.txt")
do 


	warp2metric "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" -fc "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/derivatives/MRtrix3/template/fc" "${subject}_fc.mif" 
done 

	mkdir "${data_directory}/derivatives/MRtrix3/template/log_fc"
	
	cp "${data_directory}/derivatives/MRtrix3/template/fc/index.mif" "${data_directory}/derivatives/MRtrix3/template/fc/directions.mif" "${data_directory}/derivatives/MRtrix3/template/log_fc"
	
for subject in $(cat "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI/code/sub_files.txt")
do 
	
	mrcalc "${data_directory}/derivatives/MRtrix3/template/fc/${subject}_fc.mif" -log "${data_directory}/derivatives/MRtrix3/template/log_fc/${subject}_fc.mif"
	
done 
	
echo "----------------- Computing FDC -----------------"

mkdir "${data_directory}/derivatives/MRtrix3/template/fdc"
	
	cp "${data_directory}/derivatives/MRtrix3/template/fc/index.mif" "${data_directory}/derivatives/MRtrix3/template/fdc" 
	cp "${data_directory}/derivatives/MRtrix3/template/fc/directions.mif" "${data_directory}/derivatives/MRtrix3/template/fdc"
	
for subject in $(cat "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI/code/sub_files.txt")
do 

	
	mrcalc "${data_directory}/derivatives/MRtrix3/template/fd/${subject}_fd.mif" "${data_directory}/derivatives/MRtrix3/template/fc/${subject}_fc.mif" -mult "${data_directory}/derivatives/MRtrix3/template/fdc/${subject}_fdc.mif"
	
done 



echo "----------------- Whole-brain fibre tractography on FOD template -----------------"	

	cd "${data_directory}/derivatives/MRtrix3/template"
	
	tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 "wmfod_template.mif" -seed_image "template_mask.mif" -select 20000000 -cutoff 0.06 tracks_20_million.tck
	
echo "----------------- Reduce Biases in Tractogram Desnisites -----------------"
	
	tcksift tracks_20_million.tck "wmfod_template.mif" tracks_2_million_sift.tck -term_number 2000000
		

#!/bin/sh
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 

	
		
echo "----------------- Generating Fixel-Fixel Connectivity Matrix -----------------"
	
	fixelconnectivity "${data_directory}/derivatives/MRtrix3/template/fixel_mask" ${data_directory}/derivatives/MRtrix3/template/tracks_2_million_sift.tck "${data_directory}/derivatives/MRtrix3/template/matrix"
	
echo "----------------- Smoothing Fixel data -----------------"
	

	
	fixelfilter "${data_directory}/derivatives/MRtrix3/template/fd" smooth "${data_directory}/derivatives/MRtrix3/template/fd_smooth" -matrix "${data_directory}/derivatives/MRtrix3/template/matrix" -force
	fixelfilter "${data_directory}/derivatives/MRtrix3/template/log_fc" smooth "${data_directory}/derivatives/MRtrix3/template/log_fc_smooth" -matrix "${data_directory}/derivatives/MRtrix3/template/matrix" -force
	fixelfilter "${data_directory}/derivatives/MRtrix3/template/fdc" smooth "${data_directory}/derivatives/MRtrix3/template/fdc_smooth" -matrix "${data_directory}/derivatives/MRtrix3/template/matrix" -force
	
echo "----------------- Statistical Analysis of FD FC FDC -----------------"

	fixelcfestats "${data_directory}/derivatives/MRtrix3/template/fd_smooth" "${data_directory}/code/files_fd_BDNF_FI.txt" "${data_directory}/code/design_matrix_BDNF_FI.txt" "${data_directory}/code/contrast_matrix_BDNF_FI.txt" "${data_directory}/derivatives/MRtrix3/template/matrix" "${data_directory}/derivatives/MRtrix3/template/stats_fd" -nshuffles 5000 -force
	
	fixelcfestats "${data_directory}/derivatives/MRtrix3/template/log_fc_smooth" "${data_directory}/code/files_fc_BDNF_FI.txt" "${data_directory}/code/design_matrix_BDNF_FI.txt" "${data_directory}/code/contrast_matrix_BDNF_FI.txt" "${data_directory}/derivatives/MRtrix3/template/matrix" "${data_directory}/derivatives/MRtrix3/template/stats_log_fc" -nshuffles 5000 -force

	fixelcfestats "${data_directory}/derivatives/MRtrix3/template/fdc_smooth" "${data_directory}/code/files_fdc_BDNF_FI.txt" "${data_directory}/code/design_matrix_BDNF_FI.txt" "${data_directory}/code/contrast_matrix_BDNF_FI.txt" "${data_directory}/derivatives/MRtrix3/template/matrix" "${data_directory}/derivatives/MRtrix3/template/stats_fdc" -nshuffles 5000 -force