#!/bin/bash 

# === Directories ===
data_directory=/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI
old_data_directory=/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data
template_dir="${data_directory}/derivatives/MRtrix3/template"
subjects_list="${data_directory}/code/subjects.txt"
atlas_file_hippocampus="${data_directory}/BN_Atlas_246_in_template_space.mif"
subject_dir="${data_directory}/derivatives/MRtrix3/${subject}/dwi"
fod="${subject_dir}/${subject}_wmfod_norm.mif"
warp_dir="${template_dir}/warps"
template_warp="${warp_dir}/warps/${subject}_wmfod_norm.mif"
Julich_Atlas="${data_directory}/JulichBrainAtlas_3.0_areas_MPM_b_N10_nlin2ICBM152asym2009c_public_11035603b4744231e17e87fd8ebcaf1a.nii"



# Output folders
fixel_mask="${template_dir}/fixel_mask"
density_dir="${data_directory}/derivatives/MRtrix3/tract_densities"
fbc_output_dir="${template_dir}/FBC_ch123_to_hippocampus"




# Template masks (from previous pipeline)
template_ch123_mask="${template_dir}/ch123_bilateral_mask_bin.mif"
template_hippocampus_mask="${template_dir}/Hippocampus_mask.mif"

# Ch123 

mrconvert "$Julich_Atlas" "${template_dir}/julich_mpm_3.0.mif" -force

mrcalc "${template_dir}/julich_mpm_3.0.mif" 1092 -eq "${template_dir}/ch4_right_mask.mif" -force

mrcalc "${template_dir}/julich_mpm_3.0.mif" 92 -eq "${template_dir}/ch4_left_mask.mif" -force  

mrcalc "${template_dir}/ch123_left_mask.mif" "${template_dir}/ch4_right_mask.mif" -add "${template_dir}/ch4_bilateral_mask.mif" -force

mrcalc "${template_dir}/ch123_bilateral_mask.mif" 0 -gt "${template_dir}/ch4_bilateral_mask_bin.mif" -force

#mrview "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" -overlay.load ch123_bilateral_mask_bin.mif


hip_rostral_L=215
hip_caudal_L=217
hip_rostral_R=216
hip_caudal_R=218


mrcalc "$atlas_file_hippocampus" $hip_rostral_L -eq "$atlas_file_hippocampus" $hip_caudal_L -eq -add 0 -gt "${template_dir}/HippocampusLeft_mask.mif" -force
mrcalc "$atlas_file_hippocampus" $hip_rostral_R -eq "$atlas_file_hippocampus" $hip_caudal_R -eq -add 0 -gt "${template_dir}/HippocampusRight_mask.mif" -force
mrcalc "${template_dir}/HippocampusLeft_mask.mif" "${template_dir}/HippocampusRight_mask.mif" -add 0 -gt "${template_dir}/Hippocampus_mask.mif" -force