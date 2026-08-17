#!/bin/sh
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data"

for subject in $(cat "${data_directory}/code/subjects.txt")
do

echo "----------------- converting each subjects files wmfod to MNI space -----------------"


#mrregister "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data/derivatives/MRtrix3/sub-01/dwi/sub-01_wmfod.mif" "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data/derivatives/MRtrix3/template/wmfod_template.mif" -type nonlinear -nl_warp "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data/derivatives/MRtrix3/sub-01/dwi/sub-01_subject2template_warp.mif" "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data/derivatives/MRtrix3/sub-01/dwi/sub-01_template2subject_warp.mif" -force

mrregister "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod.mif" "${data_directory}/derivatives/MRtrix3/template/wmfod_template.mif" -type nonlinear -nl_warp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_template2subject_warp.mif" -force

mrtransform "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod.mif" -warp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" -reorient_fod yes -template "${data_directory}/derivatives/MRtrix3/template/wmfod_template.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_in_template_space.mif" -force

transformconvert "${data_directory}/derivatives/MRtrix3/template/wmfod_template_2_MNI.txt" "${data_directory}/derivatives/MRtrix3/template/wmfod_template.mif" "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.nii.gz" flirt_import "${data_directory}/derivatives/MRtrix3/template/affine_warp.txt" -force

 mrtransform "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_in_template_space.mif" -linear "${data_directory}/derivatives/MRtrix3/template/affine_warp.txt" -reorient_fod yes -template "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.nii.gz" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_affine_MNI.mif" -force

mrregister "${data_directory}/derivatives/MRtrix3/template/wmfod_template.mif" "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.nii.gz" -type nonlinear -nl_warp "${data_directory}/derivatives/MRtrix3/template/template2MNI_warp.mif" "${data_directory}/derivatives/MRtrix3/template/MNI_to_template_warp.mif" -force

mrtransform "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_affine_MNI.mif" -warp "${data_directory}/derivatives/MRtrix3/template/template2MNI_warp.mif" -reorient_fod yes -template "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.nii.gz" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_in_MNI_space.mif" -force

done 
