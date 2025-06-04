#!/bin/sh
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data"
mni_FA_template="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data/MNI_FA_template.nii.gz"

mkdir -p "${data_directory}/derivatives/MRtrix3/template"

for subject in $(cat "${data_directory}/code/subjects.txt")
do
	echo "----------------- PROCESSING ${subject} -----------------"
	echo "${subject}: Started first loop" >> dwipreprocessing1.log
	mkdir "${data_directory}/derivatives/MRtrix3/${subject}"
	mkdir "${data_directory}/derivatives/MRtrix3/${subject}/dwi/"
	mkdir "${data_directory}/derivatives/MRtrix3/${subject}/anat/"

	mrtrix_directory="${data_directory}/derivatives/MRtrix3/${subject}"

	# Convert Files

	mrconvert "${data_directory}/${subject}/anat/${subject}_T1w.nii.gz" "${data_directory}/derivatives/MRtrix3/${subject}/anat/${subject}_T1w.mif" 

	mrconvert -fslgrad "${data_directory}/${subject}/dwi/${subject}_dwi.bvec" "${data_directory}/${subject}/dwi/${subject}_dwi.bval" "${data_directory}/${subject}/dwi/${subject}_dwi.nii.gz" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_dwi.mif" 

	mrconvert -fslgrad "${data_directory}/${subject}/dwi/${subject}_bdpa1.bvec" "${data_directory}/${subject}/dwi/${subject}_bdpa1.bval" "${data_directory}/${subject}/dwi/${subject}_bdpa1.nii.gz" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_bdpa1.mif" 

	mrconvert -fslgrad "${data_directory}/${subject}/dwi/${subject}_buap.bvec" "${data_directory}/${subject}/dwi/${subject}_buap.bval" "${data_directory}/${subject}/dwi/${subject}_buap.nii.gz" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_buap.mif"

	#Preprocessing

	dwidenoise "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_dwi.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den.mif" -noise "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_noise.mif"

	mrcalc "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_dwi.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den.mif" -subtract "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_residual.mif"

	mrdegibbs "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr.mif" 

	mrcat "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_buap.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_bdpa1.mif" -axis 3 "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_b0_pair.mif" 

	dwifslpreproc "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc.mif" -nocleanup -pe_dir AP -rpe_pair -se_epi "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_b0_pair.mif" -eddy_options " --slm=linear --data_is_shelled"
	 
	#mrconvert  "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc.nii"
	
	#bet  "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc.nii" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_temp_mask.nii" -m
	
	#mrconvert "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_temp_mask.nii" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_temp_mask.mif"
	
	
	dwibiascorrect ants "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased.mif" -bias "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_bias.mif"
	echo "${subject}: Finished first loop" >> dwipreprocessing1.log
done



# Normalisation Across Subjects

mkdir -p "${data_directory}/derivatives/MRtrix3/response_estimation/dwi_input"
mkdir -p "${data_directory}/derivatives/MRtrix3/response_estimation/mask_input"

for subject in $(cat "${data_directory}/code/subjects.txt")
do
	echo "----------------- Linking ${subject} -----------------"

	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased.mif" "${data_directory}/derivatives/MRtrix3/response_estimation/dwi_input/${subject}_den_unr_preproc_unbiased.mif"

	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_temp_mask.mif" "${data_directory}/derivatives/MRtrix3/response_estimation/mask_input/${subject}_temp_mask.mif"

done

for subject in $(cat "${data_directory}/code/subjects.txt")
do

	mv "${data_directory}/derivatives/MRtrix3/response_estimation/dwi_output/${subject}_den_unr_preproc_unbiased.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased.mif"

#FBA Analysis Steps
echo "----------------- Start of FBA -----------------"

	dwi2response dhollander "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_response_wm.txt" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_response_gm.txt" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_response_csf.txt" 
			
done

mkdir -p "${data_directory}/derivatives/MRtrix3/response_estimation/sub_responses_wm"
mkdir -p "${data_directory}/derivatives/MRtrix3/response_estimation/sub_responses_gm"
mkdir -p "${data_directory}/derivatives/MRtrix3/response_estimation/sub_responses_csf"

for subject in $(cat "${data_directory}/code/subjects.txt")
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

for subject in $(cat "${data_directory}/code/subjects.txt")
do

	mrgrid "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased.mif" regrid -vox 1.25 "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.mif" 
	
	mrconvert "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.nii" -force
	
	bet "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.nii" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_mask_upsampled.nii" -m
	
	mrconvert "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_mask_upsampled.nii.gz" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_mask_upsampled.mif"

	
done 


echo "----------------- Starting FOD Estimation -----------------"	
for subject in $(cat "${data_directory}/code/subjects.txt")
do
	sub_file="${data_directory}/derivatives/MRtrix3/${subject}/dwi"
	dwi_file="${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_upsampled.mif"
	
	wm_response="${data_directory}/derivatives/MRtrix3/group_average_response_wm.txt"
	gm_response="${data_directory}/derivatives/MRtrix3/group_average_response_gm.txt"
	csf_response="${data_directory}/derivatives/MRtrix3/group_average_response_csf.txt"

	 
	dwi2fod msmt_csd $dwi_file $wm_response "${sub_file}/${subject}_wmfod.mif" $gm_response "${sub_file}/${subject}_gmfod.mif" $csf_response "${sub_file}/${subject}_csffod.mif"  -mask "${sub_file}/${subject}_mask_upsampled.mif"
	
	mtnormalise "${sub_file}/${subject}_wmfod.mif" "${sub_file}/${subject}_wmfod_norm.mif" "${sub_file}/${subject}_gmfod.mif" "${sub_file}/${subject}_gmfod_norm.mif" "${sub_file}/${subject}_csffod.mif" "${sub_file}/${subject}_csffod_norm.mif" -mask "${sub_file}/${subject}_mask_upsampled.mif"
done	
	
echo "----------------- Generating FOD Template -----------------"

mkdir -p "${data_directory}/derivatives/MRtrix3/template/fod_input"
mkdir    "${data_directory}/derivatives/MRtrix3/template/mask_input"	

for subject in $(cat "${data_directory}/code/subjects.txt")

do

	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_norm.mif" "${data_directory}/derivatives/MRtrix3/template/fod_input/${subject}_wmfod_norm.mif"

	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_mask_upsampled.mif" "${data_directory}/derivatives/MRtrix3/template/mask_input/${subject}_mask_upsampled.mif"
	
done



	population_template "${data_directory}/derivatives/MRtrix3/template/fod_input" -mask_dir "${data_directory}/derivatives/MRtrix3/template/mask_input/" "${data_directory}/derivatives/MRtrix3/template/wmfod_template.mif" -voxel_size 1.25 -warp_dir "${data_directory}/derivatives/MRtrix3/template/warps"

echo "----------------- Co-register the study specific population template to MNI space using FA based affine registration -----------------"


mrconvert "${data_directory}/derivatives/MRtrix3/template/wmfod_template.mif" "${data_directory}/derivatives/MRtrix3/template/wmfod_template_bad_strides.nii.gz" -force

mrconvert "${data_directory}/derivatives/MRtrix3/template/wmfod_template_bad_strides.nii.gz" "${data_directory}/derivatives/MRtrix3/template/wmfod_template.nii.gz" -strides -1,2,3,4 -force

mrconvert "${data_directory}/derivatives/MRtrix3/template/wmfod_template.nii.gz" "${data_directory}/derivatives/MRtrix3/template/l0image.nii.gz" -coord 3 0 -force

# Somewhere in my code, something makes somevalues NaN. Probably a convert or regrid or transform (I think it will be a mrgrid step need to set -fill to 0s?)
fslmaths "${data_directory}/derivatives/MRtrix3/template/l0image.nii.gz" -nan "${data_directory}/derivatives/MRtrix3/template/l0image.nii.gz"

flirt -in "${data_directory}/derivatives/MRtrix3/template/l0image.nii.gz" -ref $mni_FA_template -out "${data_directory}/derivatives/MRtrix3/template/l0image_MNI.nii.gz" -omat "${data_directory}/derivatives/MRtrix3/template/wmfod_template_2_MNI.mat" -dof 12

transformconvert "${data_directory}/derivatives/MRtrix3/template/wmfod_template_2_MNI.mat" "${data_directory}/derivatives/MRtrix3/template/l0image.nii.gz" $mni_FA_template flirt_import "${data_directory}/derivatives/MRtrix3/template/wmfod_template_2_MNI.txt" -force

# Should the reorient_fod be "true" or "false"
mrtransform "${data_directory}/derivatives/MRtrix3/template/wmfod_template.nii.gz" -linear "${data_directory}/derivatives/MRtrix3/template/wmfod_template_2_MNI.txt" -template $mni_FA_template "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.nii.gz" -reorient_fod true -force



mrconvert "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.nii.gz" "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" -force



echo "----------------- Registering Subjects to FOD Template -----------------"


for subject in $(cat "${data_directory}/code/subjects.txt")

do

	sub_file="${data_directory}/derivatives/MRtrix3/${subject}/dwi"
	
	
	mrregister "${sub_file}/${subject}_wmfod_norm.mif" -mask1 "${sub_file}/${subject}_mask_upsampled.mif" "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" -nl_warp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_template2subject_warp.mif"
	
	mrtransform "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_mask_upsampled.mif" -warp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" -interp nearest -datatype bit "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_mask_in_template_space.mif" 
	 
done 