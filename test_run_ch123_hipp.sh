#!/bin/bash

# === Directories and Variables ===
data_directory=/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI
template_dir="${data_directory}/derivatives/MRtrix3/template"
subjects_list="${data_directory}/code/sub_files.txt"
atlas_file_hippocampus="${data_directory}/BN_Atlas_246_in_template_space.mif"
Julich_Atlas="${data_directory}/JulichBrainAtlas_3.0_areas_MPM_b_N10_nlin2ICBM152asym2009c_public_11035603b4744231e17e87fd8ebcaf1a.nii"

mkdir -p "$template_dir/FBC_ch123_to_hippocampus"
mkdir -p "$data_directory/derivatives/MRtrix3/tract_densities"

# === Generate Ch123 and Hippocampus Masks ===
mrconvert "$Julich_Atlas" "$template_dir/julich_mpm_3.0.mif" -force
mrcalc "$template_dir/julich_mpm_3.0.mif" 1097 -eq "$template_dir/ch123_right_mask.mif" -force
mrcalc "$template_dir/julich_mpm_3.0.mif" 97 -eq "$template_dir/ch123_left_mask.mif" -force
mrcalc "$template_dir/ch123_left_mask.mif" "$template_dir/ch123_right_mask.mif" -add "$template_dir/ch123_bilateral_mask.mif" -force
mrcalc "$template_dir/ch123_bilateral_mask.mif" 0 -gt "$template_dir/ch123_bilateral_mask_bin.mif" -force

hip_rostral_L=215
hip_caudal_L=217
hip_rostral_R=216
hip_caudal_R=218

mrcalc "$atlas_file_hippocampus" $hip_rostral_L -eq "$atlas_file_hippocampus" $hip_caudal_L -eq -add 0 -gt "$template_dir/HippocampusLeft_mask.mif" -force
mrcalc "$atlas_file_hippocampus" $hip_rostral_R -eq "$atlas_file_hippocampus" $hip_caudal_R -eq -add 0 -gt "$template_dir/HippocampusRight_mask.mif" -force
mrcalc "$template_dir/HippocampusLeft_mask.mif" "$template_dir/HippocampusRight_mask.mif" -add 0 -gt "$template_dir/Hippocampus_mask.mif" -force

# === Transform Atlas Masks to Subject Space ===
echo "----------------- Subject-level Registration -----------------"
for subject in $(cat "$subjects_list"); do
  echo "Registering masks for subject: $subject"

  subject_dir="$data_directory/derivatives/MRtrix3/${subject}/dwi"
  tract_dir="$subject_dir/tracts_ch123_to_hippocampus"
  fod="$subject_dir/${subject}_wmfod_norm.mif"
  warp_dir="$template_dir/warps"
  template_warp="$warp_dir/${subject}_wmfod_norm.mif"
  mkdir -p "$subject_dir/tracts_ch123_to_hippocampus"

  mrtransform -linear "$template_dir/wmfod_template_2_MNI.txt" -inverse "$template_dir/Hippocampus_mask.mif" "$template_dir/hippocampus_in_template_space.mif" -template "$template_dir/wmfod_template.mif" -interp nearest -datatype bit -force
  mrtransform -warp_full "$template_warp" -from 2 "$template_dir/hippocampus_in_template_space.mif" "$subject_dir/hippocampus_in_subject_space.mif" -template "$fod" -interp nearest -datatype bit -force
  mrtransform -linear "$template_dir/linear_transforms/${subject}_wmfod_norm.txt" -inverse "$subject_dir/hippocampus_in_subject_space.mif" "$subject_dir/hippocampus_in_subject_space_warped_to_template.mif" -template "$fod" -interp nearest -datatype bit -force




  mrtransform -linear "$template_dir/wmfod_template_2_MNI.txt" -inverse "$template_dir/ch123_bilateral_mask_bin.mif" "$template_dir/ch123_in_template_space.mif" -template "$template_dir/wmfod_template.mif" -interp nearest -datatype bit -force
  mrtransform -warp_full "$template_warp" -from 2 "$template_dir/ch123_in_template_space.mif" "$subject_dir/ch123_in_subject_space.mif" -template "$fod" -interp nearest -datatype bit -force
  mrtransform -linear "$template_dir/linear_transforms/${subject}_wmfod_norm.txt" -inverse "$subject_dir/ch123_in_subject_space.mif" "$subject_dir/ch123_in_subject_space_warped_to_template.mif" -template "$fod" -interp nearest -datatype bit -force

done 
# === Generate Tract-specific Fixel Mask ===

for subject in $(cat "$subjects_list"); do
  echo "Generating whole-brain tractogram: $subject"

  subject_dir="$data_directory/derivatives/MRtrix3/${subject}/dwi"
  tract_dir="$subject_dir/tracts_ch123_to_hippocampus"
  fod="$subject_dir/${subject}_wmfod_norm.mif"
  warp_dir="$template_dir/warps"
  template_warp="$warp_dir/${subject}_wmfod_norm.mif"

tckgen "$fod" "${tract_dir}/${subject}_wholebrain.tck" \
    -seed_dynamic "$fod" \
    -algorithm iFOD2 \
    -select 20000000 \
    -cutoff 0.06 \
    -minlength 10 -maxlength 250 \
    -force
echo " -> Computing SIFT2 weights..."
tcksift2 "$tract_dir/${subject}_wholebrain.tck" "$fod" "$tract_dir/${subject}_sift2_weights.txt" -force
echo " -> Filtering streamlines from Ch123 to Hippocampus..."
tckedit "${tract_dir}/${subject}_wholebrain.tck" \
    -include "$subject_dir/ch123_in_subject_space.mif" \
    -include "$subject_dir/hippocampus_in_subject_space.mif" \
    -tck_weights_in "${tract_dir}/${subject}_sift2_weights.txt" \
    -tck_weights_out "${tract_dir}/${subject}_sift2_weights_filtered.txt" \
    -ends_only \
    "${tract_dir}/${subject}_tracts_filtered.tck" -force
echo " -> Creating voxel-wise streamline density map..."
 tckmap "${tract_dir}/${subject}_tracts_filtered.tck" "${tract_dir}/${subject}_voxel_density.mif" \
         -template "${subject_dir}/${subject}_wmfod_norm.mif" \
         -tck_weights_in "${tract_dir}/${subject}_sift2_weights_filtered.txt" \
         -precise -force

done 

echo " -> Creating template-space fixel mask from Ch123-to-Hippocampus tract..."

echo " -> Extracting tract from population tractogram..."
tckedit "${template_dir}/tracks_20_million.tck" \
  -include "${template_dir}/ch123_in_template_space.mif" \
  -include "${template_dir}/hippocampus_in_template_space.mif" \
  -ends_only \
  "$template_dir/tract_ch123_to_hipp_template.tck" -force

# 2. Create binary voxel mask from tract in template space
tckmap "${template_dir}/tract_ch123_to_hipp_template.tck" "${template_dir}/tract_mask_template.mif" \
        -template "$template_dir/wmfod_template_MNI.mif" -contrast tdi -force

# 3. Generate fixel mask from tract-restricted FOD template
rm -rf "${template_dir}/fixel_mask_ch123_to_hipp"
fod2fixel "${template_dir}/wmfod_template_MNI.mif" "${template_dir}/fixel_mask_ch123_to_hipp" \
           -mask "$template_dir/tract_mask_template.mif" -force

# 4. Map tract to fixels to define fixel-wise density


tck2fixel "${template_dir}/tract_ch123_to_hipp_template.tck" \
          "${template_dir}/fixel_mask_ch123_to_hipp" \
          "${template_dir}/fixel_mask_ch123_to_hipp_tracks" \
          "${template_dir}/template_fixel_track_density.mif" -force

# === Subject-level Tractography and FBC ===
echo "----------------- Running Subject-Level FBC -----------------"
for subject in $(cat "$subjects_list"); do
  echo "Processing subject: $subject"

  subject_dir="$data_directory/derivatives/MRtrix3/${subject}/dwi"
  tract_dir="$subject_dir/tracts_ch123_to_hippocampus"
  fod="$subject_dir/${subject}_wmfod_norm.mif"
  fd_map="$template_dir/fd/${subject}_fd.mif"
  warp="$subject_dir/${subject}_subject2template_warp.mif"
  ch123_mask="$subject_dir/ch123_in_subject_space_warped_to_template.mif"
  hippocampus_mask="$subject_dir/hippocampus_in_subject_space_warped_to_template.mif"
  fbc_output_dir="$template_dir/FBC_ch123_to_hippocampus"
  mkdir -p "${subject_dir}/tracts_ch123_to_hippocampus/fixel_data"
  mkdir -p "$tract_dir/fixel_data"

 # Warp FD map to template space
mrtransform "${template_dir}/fd/${subject}_fd.mif" -warp "${subject_dir}/${subject}_subject2template_warp.mif" -template "${template_dir}/wmfod_template_MNI.mif" "${tract_dir}/${subject}_fd_in_template.mif" -force

# Warp voxel density map to template space before voxel2fixel
mrtransform "${tract_dir}/${subject}_voxel_density.mif" -warp "${subject_dir}/${subject}_subject2template_warp.mif" -template "${template_dir}/wmfod_template_MNI.mif" "${tract_dir}/${subject}_voxel_density_in_template_space.mif" -force
# === Step 6: Convert to fixel-wise streamline density ===
mkdir -p "${subject_dir}/tracts_ch123_to_hippocampus/fixel_data"

voxel2fixel "${subject_dir}/tracts_ch123_to_hippocampus/${subject}_voxel_density_in_template_space.mif" "$template_dir/fixel_mask_ch123_to_hipp" "${subject_dir}/tracts_ch123_to_hippocampus/fixel_data" "${subject}_streamline_density_fixel.mif" -force
# === Step 7: Compute mean streamline length ===
echo " -> Computing mean streamline length..."
tckstats "${tract_dir}/${subject}_tracts_filtered.tck" -dump lengths.txt -force
mean_length=$(awk '{ total += $1; count++ } END { printf "%.6f", total/count }' lengths.txt)

# Convert FD to fixel space
echo " -> Converting FD to fixel space..."
voxel2fixel "${tract_dir}/${subject}_fd_in_template.mif" "${template_dir}/fixel_mask_ch123_to_hipp" "${tract_dir}/fixel_data" "${subject}_fd_fixel.mif" -force


echo " -> Calculating FBC (FD × streamline density / mean length)..."
# Multiply FD × streamline density
mrcalc "${tract_dir}/fixel_data/${subject}_fd_fixel.mif" "${tract_dir}/fixel_data/${subject}_streamline_density_fixel.mif" -mult "${tract_dir}/fixel_data/${subject}_numerator.mif" -force
mrcalc "${tract_dir}/fixel_data/${subject}_numerator.mif" "$mean_length" -div "${tract_dir}/fixel_data/${subject}_fbc.mif" -force

# Copy FBC map to group-level folder for fixelcfestats
cp "${tract_dir}/fixel_data/${subject}_fbc.mif" "$fbc_output_dir/${subject}_fbc.mif"

echo " Finished subject: $subject"

done

echo " All subjects processed for FBC."


echo " Starting fixelconnectivity and stats..."
# === Connectivity & stats using tract-specific fixel mask in template space ===
fixelconnectivity "${template_dir}/fixel_mask_ch123_to_hipp" "${template_dir}/tract_ch123_to_hipp_template.tck" "${template_dir}/fixel_mask_ch123_to_hipp/connectivity.mif" -force

rm -rf "$template_dir/stats_fbc"

fbc_output_dir="$template_dir/FBC_ch123_to_hippocampus"
files_fbc="${data_directory}/code/files_fbc_BDNF_FI.txt"
design_matrix="${data_directory}/code/design_matrix_fbc_BDNF_FI.txt"
contrast_matrix="${data_directory}/code/contrast_matrix_fbc_BDNF_FI.txt"


fixelcfestats "$fbc_output_dir" "$files_fbc" "$design_matrix" "$contrast_matrix" "$template_dir/fixel_mask_ch123_to_hipp/connectivity.mif" "$template_dir/stats_fbc" -nshuffles 5000 -force