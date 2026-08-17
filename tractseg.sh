#!/bin/sh
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data" 

mkdir -p "${data_directory}/derivatives/MRtrix3/tract_files"
mkdir -p "${data_directory}/derivatives/MRtrix3/tract_fixels"
mkdir -p "${data_directory}/derivatives/MRtrix3/tract_TDis/FX"
mkdir -p "${data_directory}/derivatives/MRtrix3/tract_fixels/fd/FX"

mkdir -p "${data_directory}/template/tract_segmentation"



#mrconvert "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.nii.gz"

#To do: 1) find out why there is an endings_segmentation folder in the endings_segmentation folder 2) for each subjet create peaks file from wmfod files and put them into MNI space - i already have subject2template and template2MNI but i need to find a way to stitch them together 




#what i did 17/1: mv template/endings_segmentation template/tract_segmentation
for subject in $(cat "${data_directory}/code/subjects.txt")
do
	echo "----------------- Applying Tractseg -----------------"
	sh2peaks "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_in_MNI_space.mif" "peaks.nii.gz" -force
done 

TractSeg -i "peaks.nii.gz" -o "template/tract_segmentation/" --output_type "tract_segmentation"

TractSeg -i "peaks.nii.gz" -o "template/tract_segmentation/" --output_type "endings_segmentation"

TractSeg -i "peaks.nii.gz" -o "template/tract_segmentation/" --output_type "TOM"

Tracking -i "peaks.nii.gz" -o "template/tract_segmentation/" --tracking_format tck --nr_fibers 10000 








