#!/bin/sh
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data"
mni_FA_template="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data/MNI_FA_template.nii.gz"

echo "----------------- Co-register the study specific population template to MNI space using FA based affine registration -----------------"

mkdir "${data_directory}/derivatives/MRtrix3/template/MNI_FA_template"

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

