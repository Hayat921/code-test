#!/bin/sh
data_directory="/home/hkhe451/phd-projects/BDNF-project/BDNF_project_data"
subject="sub-01"
mkdir "${data_directory}/derivatives/MRtrix3_Tractography/${subject}/"
mkdir "${data_directory}/derivatives/MRtrix3_Tractography/${subject}/tract/"

mrtrix_directory="${data_directory}/derivatives/MRtrix3/${subject}"
mrtrix_tractography_directory="${data_directory}/derivatives/MRtrix3_Tractography/${subject}/tract"

#Streamlines - Anatomically Constrained Tractography 

tckgen -act "${data_directory}/derivatives/MRtrix3/${subject}/anat/${subject}_T1w_coreg.mif" -backtrack -seed_gmwmi "${data_directory}/derivatives/MRtrix3/${subject}/anat/${subject}_T1w_gmwmSeed_coreg.mif" -nthreads 8 -maxlength 250 -cutoff 0.06 -select 10000000 "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_norm.mif" "${mrtrix_tractography_directory}/${subject}_T1w_tracks_10m.tck"

tckedit "${mrtrix_tractography_directory}/${subject}_T1w_tracks_10m.tck" -number 200k  "${mrtrix_tractography_directory}/${subject}_T1w_subsampleTracks_200k.tck"

#mrview "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_preproc_unbiased.mif" -tractography.load "${mrtrix_tractography_directory}/${subject}_T1w_subsampleTracks_200k.tck"

tcksift2 -act "${data_directory}/derivatives/MRtrix3/${subject}/anat/${subject}_T1w_coreg.mif" -out_mu "${mrtrix_tractography_directory}/${subject}_T1w_sift_mu.txt" -out_coeffs "${mrtrix_tractography_directory}/${subject}_T1w_sift_coeffs.txt" -nthreads 8 "${mrtrix_tractography_directory}/${subject}_T1w_tracks_10m.tck" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_norm.mif" "${mrtrix_tractography_directory}/${subject}_sift_1m.txt" 



mv "${data_directory}/derivatives/MRtrix3/dwinormalise/dwi_output/${subject}_den_unr_preproc_unbiased.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_den_unr_preproc_unbiased_normalised.mif"
