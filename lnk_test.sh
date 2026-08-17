#!/bin/sh
# Normalisation Across Subjects

mkdir -p "${data_directory}/derivatives/MRtrix3/dwinormalise/dwi_input"
mkdir -p "${data_directory}/derivatives/MRtrix3/dwinormalise/mask_input"

for subject in $(cat "${data_directory}/code/subjects.txt")
do
	echo "----------------- Linking ${subject} -----------------"

	ln -sr "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_preproc_unbiased.mif" "${data_directory}/derivatives/MRtrix3/dwinormalise/${subject}_den_preproc_unbiased.mif"

	ln -sr "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}/${subject}_temp_mask.mif" "${data_directory}/derivatives/MRtrix3/dwinormalise/${subject}_temp_mask.mif"

done
