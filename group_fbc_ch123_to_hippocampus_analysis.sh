#!/bin/bash

# Set directories
# Data root
data_directory=/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data

# Template and subject list
template_dir=/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data/derivatives/MRtrix3/template
subjects_list=/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data/code/subjects.txt

# Output folders
fixel_mask=${template_dir}/fixel_mask
density_dir=/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data/derivatives/MRtrix3/tract_densities
fbc_output_dir=/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data/derivatives/MRtrix3/template/FBC_ch123_to_hippocampus

mkdir -p "$density_dir"
mkdir -p "$fbc_output_dir"

echo "----------------- Subject-level FBC pipeline -----------------"

for subject in $(cat "$subjects_list")
do
  echo "Processing subject: ${subject}"

  # Step 1: Whole-brain tractography (MNI-space FOD)
  tckgen "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_in_MNI_space.mif" \
         "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_tracts.tck" \
         -seed_dynamic "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_in_MNI_space.mif" \
         -algorithm iFOD2 \
         -select 10000000 \
         -cutoff 0.06 \
         -minlength 10 -maxlength 250 \
         -force

  # Step 2: SIFT2
  tcksift2 "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_tracts.tck" \
           "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_in_MNI_space.mif" \
           "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_sift2_weights.txt" \
           -force

  # Step 2.5: Transform template tract to subject space
  tcktransform "${template_dir}/tract_ch123_to_hippocampus_filtered.tck" \
               "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_template2subject_warp.mif" \
               "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_tract_ch123_to_hippocampus.tck" \
     



for subject in $(cat "$subjects_list")
do
  echo "Processing subject: ${subject}"
  # Step 3: Create voxel-wise streamline density
  tckmap "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_tract_ch123_to_hippocampus.tck" \
         "${density_dir}/${subject}_voxel_density.mif" \
         -template "${template_dir}/wmfod_template_MNI.mif" \
         -tck_weights_in "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_sift2_weights.txt" \
         -precise \
         -force

done 
  # Step 4: Convert to fixel-wise streamline density
  voxel2fixel "${density_dir}/${subject}_voxel_density.mif" \
              "$fixel_mask" \
              "$density_dir" \
              "${density_dir}/${subject}_streamline_density_fixel.mif" \
              -force

  # Step 5: FBC = FD × streamline_density
  mrcalc "${template_dir}/fd/${subject}_fd.mif" \
         "${density_dir}/${subject}_streamline_density_fixel.mif" \
         -mult "${fbc_output_dir}/${subject}_FBC.mif" \
         -force

  echo "✅ FBC complete for ${subject}"
done



