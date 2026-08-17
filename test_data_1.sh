#!/bin/sh

# --- Make FSL visible in non-login shells ---
# Try the global profile first:
if [ -r /etc/profile.d/fsl.sh ]; then
  . /etc/profile.d/fsl.sh
fi


data_directory="/media/hkhe451/Expansion/phd-projects/test_data"


mkdir -p "${data_directory}/derivatives/MRtrix3/template"

for subject in $(cat "/media/hkhe451/Expansion/phd-projects/test_data/code/sub_files.txt")
do 

echo "----------------- PROCESSING ${subject} -----------------"
	echo "${subject}: Started first loop" >> test_data_1.log
	mkdir "${data_directory}/derivatives/MRtrix3/${subject}"
	mkdir "${data_directory}/derivatives/MRtrix3/${subject}/dwi/"
	mkdir "${data_directory}/derivatives/MRtrix3/${subject}/anat/"



mrconvert -fslgrad "${data_directory}/${subject}/${subject}_acq_data_dwi.bvec" "${data_directory}/${subject}/${subject}_acq_data_dwi.bval" "${data_directory}/${subject}/${subject}_acq_data_dwi.nii" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased.mif" -force


mrgrid "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased.mif" regrid -voxel 2.0 "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.mif" -force

dwi2mask "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_temp_mask.mif"

done 

mkdir -p "${data_directory}/derivatives/MRtrix3/response_estimation/dwi_input"
mkdir -p "${data_directory}/derivatives/MRtrix3/response_estimation/mask_input"

for subject in $(cat "/media/hkhe451/Expansion/phd-projects/test_data/code/sub_files.txt")
do   
	echo "----------------- Linking ${subject} -----------------"

	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.mif" "${data_directory}/derivatives/MRtrix3/response_estimation/dwi_input/${subject}_den_unr_preproc_unbiased_upsampled.mif"

	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_temp_mask.mif" "${data_directory}/derivatives/MRtrix3/response_estimation/mask_input/${subject}_temp_mask.mif"

done

for subject in $(cat "/media/hkhe451/Expansion/phd-projects/test_data/code/sub_files.txt")
do 
#i changed the below file from dwi_output to dwi_input because i got a mv cannot stat error
	mv "${data_directory}/derivatives/MRtrix3/response_estimation/dwi_input/${subject}_den_unr_preproc_unbiased_upsampled.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.mif"


#FBA Analysis Steps
echo "----------------- Start of FBA -----------------"

	dwi2response dhollander "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_response_wm.txt" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_response_gm.txt" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_response_csf.txt" -force
			
done

mkdir -p "${data_directory}/derivatives/MRtrix3/response_estimation/sub_responses_wm"
mkdir -p "${data_directory}/derivatives/MRtrix3/response_estimation/sub_responses_gm"
mkdir -p "${data_directory}/derivatives/MRtrix3/response_estimation/sub_responses_csf"

for subject in $(cat "/media/hkhe451/Expansion/phd-projects/test_data/code/sub_files.txt")
do 

    cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_response_wm.txt" "${data_directory}/derivatives/MRtrix3/response_estimation/sub_responses_wm/${subject}_response_wm.txt"
	
	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_response_gm.txt" "${data_directory}/derivatives/MRtrix3/response_estimation/sub_responses_gm/${subject}_response_gm.txt"
	
	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_response_csf.txt" "${data_directory}/derivatives/MRtrix3/response_estimation/sub_responses_csf/${subject}_response_csf.txt"
done 

cd "${data_directory}/derivatives/MRtrix3/response_estimation/sub_responses_wm/"
responsemean $(ls) "${data_directory}/derivatives/MRtrix3/group_average_response_wm.txt" 

cd "${data_directory}/derivatives/MRtrix3/response_estimation/sub_responses_gm/"
responsemean $(ls) "${data_directory}/derivatives/MRtrix3/group_average_response_gm.txt" 

cd "${data_directory}/derivatives/MRtrix3/response_estimation/sub_responses_csf/"
responsemean $(ls) "${data_directory}/derivatives/MRtrix3/group_average_response_csf.txt" 
cd "${data_directory}/code/"

for subject in $(cat "/media/hkhe451/Expansion/phd-projects/test_data/code/sub_files.txt")
do
	#mrgrid "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased.mif" regrid -vox 2.0 "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.mif" 
	
	mrconvert "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.nii" -force
	
	bet "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.nii" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_bet_upsampled.nii" -m
	
	mrconvert "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_bet_upsampled_mask.nii.gz" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_bet_upsampled_mask.mif"

	
done 


echo "----------------- Starting FOD Estimation -----------------"	
for subject in $(cat "/media/hkhe451/Expansion/phd-projects/test_data/code/sub_files.txt")
do  
	sub_file="${data_directory}/derivatives/MRtrix3/${subject}/dwi"
	dwi_file="${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.mif"
	
	wm_response="${data_directory}/derivatives/MRtrix3/group_average_response_wm.txt"
	gm_response="${data_directory}/derivatives/MRtrix3/group_average_response_gm.txt"
	csf_response="${data_directory}/derivatives/MRtrix3/group_average_response_csf.txt"

	 
	dwi2fod msmt_csd $dwi_file $wm_response "${sub_file}/${subject}_wmfod.mif" $gm_response "${sub_file}/${subject}_gmfod.mif" $csf_response "${sub_file}/${subject}_csffod.mif"  -mask "${sub_file}/${subject}_bet_upsampled_mask.mif"
	
	mtnormalise "${sub_file}/${subject}_wmfod.mif" "${sub_file}/${subject}_wmfod_norm.mif" "${sub_file}/${subject}_gmfod.mif" "${sub_file}/${subject}_gmfod_norm.mif" "${sub_file}/${subject}_csffod.mif" "${sub_file}/${subject}_csffod_norm.mif" -mask "${sub_file}/${subject}_bet_upsampled_mask.mif"
done	
	
echo "----------------- Generating FOD Template -----------------"

mkdir -p "${data_directory}/derivatives/MRtrix3/template/fod_input"
mkdir    "${data_directory}/derivatives/MRtrix3/template/mask_input"

for subject in $(cat "/media/hkhe451/Expansion/phd-projects/test_data/code/sub_files.txt")
do 

	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_norm.mif" "${data_directory}/derivatives/MRtrix3/template/fod_input/${subject}_wmfod_norm.mif"

	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_bet_upsampled_mask.mif" "${data_directory}/derivatives/MRtrix3/template/mask_input/${subject}_bet_upsampled_mask.mif"
	
done



	population_template "${data_directory}/derivatives/MRtrix3/template/fod_input" -mask_dir "${data_directory}/derivatives/MRtrix3/template/mask_input/" "${data_directory}/derivatives/MRtrix3/template/wmfod_template.mif" -voxel_size 2.0 -warp_dir "${data_directory}/derivatives/MRtrix3/template/warps" -linear_transformations_dir "${data_directory}/derivatives/MRtrix3/template/linear_transforms" -force

echo "----------------- Co-register the study specific population template to MNI space using FA based affine registration -----------------"


mrconvert "${data_directory}/derivatives/MRtrix3/template/wmfod_template.mif" "${data_directory}/derivatives/MRtrix3/template/wmfod_template_bad_strides.nii.gz" -force

mrconvert "${data_directory}/derivatives/MRtrix3/template/wmfod_template_bad_strides.nii.gz" "${data_directory}/derivatives/MRtrix3/template/wmfod_template.nii.gz" -strides -1,2,3,4 -force

mrconvert "${data_directory}/derivatives/MRtrix3/template/wmfod_template.nii.gz" "${data_directory}/derivatives/MRtrix3/template/l0image.nii.gz" -coord 3 0 -force

# Somewhere in my code, something makes somevalues NaN. Probably a convert or regrid or transform (I think it will be a mrgrid step need to set -fill to 0s?)
fslmaths "${data_directory}/derivatives/MRtrix3/template/l0image.nii.gz" -nan "${data_directory}/derivatives/MRtrix3/template/l0image.nii.gz"

flirt -in "${data_directory}/derivatives/MRtrix3/template/l0image.nii.gz" -ref "/media/hkhe451/Expansion/phd-projects/test_data/MNI_FA_template.nii.gz" -out "${data_directory}/derivatives/MRtrix3/template/l0image_MNI.nii.gz" -omat "${data_directory}/derivatives/MRtrix3/template/wmfod_template_2_MNI.mat" -dof 12

transformconvert "${data_directory}/derivatives/MRtrix3/template/wmfod_template_2_MNI.mat" "${data_directory}/derivatives/MRtrix3/template/l0image.nii.gz" "/media/hkhe451/Expansion/phd-projects/test_data/MNI_FA_template.nii.gz" flirt_import "${data_directory}/derivatives/MRtrix3/template/wmfod_template_2_MNI.txt" -force

mrtransform "${data_directory}/derivatives/MRtrix3/template/wmfod_template.nii.gz" -linear "${data_directory}/derivatives/MRtrix3/template/wmfod_template_2_MNI.txt" -template "/media/hkhe451/Expansion/phd-projects/test_data/MNI_FA_template.nii.gz" "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.nii.gz" -reorient_fod true -force

mrconvert "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.nii.gz" "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" -force



echo "----------------- Registering Subjects to FOD Template -----------------"

for subject in $(cat "/media/hkhe451/Expansion/phd-projects/test_data/code/sub_files.txt")
do 

	sub_file="${data_directory}/derivatives/MRtrix3/${subject}/dwi"
	
	
	mrregister "${sub_file}/${subject}_wmfod_norm.mif" -mask1 "${sub_file}/${subject}_bet_upsampled_mask.mif" "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" -nl_warp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_template2subject_warp.mif"
	
	mrtransform "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_bet_upsampled_mask.mif" -warp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" -interp nearest -datatype bit "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_mask_in_template_space.mif" 
	 
done 

#glass brain
mrmath "${data_directory}/derivatives/MRtrix3"/*/dwi/*_mask_in_template_space.mif mean \
"${data_directory}/derivatives/MRtrix3/template/template_mask_mean.mif"

mrgrid "${data_directory}/derivatives/MRtrix3/template/template_mask_mean.mif" regrid -scale 1.5 \
"${data_directory}/derivatives/MRtrix3/template/template_mask_mean_up.mif" -force

mrfilter "${data_directory}/derivatives/MRtrix3/template/template_mask_mean_up.mif" smooth -stdev 2 \
"${data_directory}/derivatives/MRtrix3/template/template_mask_smooth.mif" -force

mrthreshold "${data_directory}/derivatives/MRtrix3/template/template_mask_smooth.mif" -abs 0.5 \
"${data_directory}/derivatives/MRtrix3/template/template_mask_thres.mif" -force

maskfilter "${data_directory}/derivatives/MRtrix3/template/template_mask_thres.mif" dilate -npass 2 \
"${data_directory}/derivatives/MRtrix3/template/template_mask_dilated.mif" -force

mrcalc "${data_directory}/derivatives/MRtrix3/template/template_mask_dilated.mif" \
"${data_directory}/derivatives/MRtrix3/template/template_mask_thres.mif" -subtract \
"${data_directory}/derivatives/MRtrix3/template/glass_brain.mif" -force