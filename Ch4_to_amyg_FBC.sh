#!/bin/bash

# === Directories and Variables ===
data_directory=/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI
template_dir="${data_directory}/derivatives/MRtrix3/template"
subjects_list="${data_directory}/code/sub_files.txt"
Julich_Atlas="${data_directory}/JulichBrainAtlas_3.0_areas_MPM_b_N10_nlin2ICBM152asym2009c_public_11035603b4744231e17e87fd8ebcaf1a.nii"

mkdir -p "$template_dir/ch4_to_amyg" 
mkdir -p "$data_directory/derivatives/MRtrix3/tract_densities_ch4_to_amyg"


mrconvert "$Julich_Atlas" "${template_dir}/julich_mpm_3.0.mif" -force

# Amygdala - CM
mrcalc "${template_dir}/julich_mpm_3.0.mif" 1101 -eq "${template_dir}/amyg_CM_right_mask.mif" -force
mrcalc "${template_dir}/julich_mpm_3.0.mif" 101 -eq "${template_dir}/amyg_CM_left_mask.mif" -force  
mrcalc "${template_dir}/amyg_CM_right_mask.mif" "${template_dir}/amyg_CM_left_mask.mif" -add "${template_dir}/amyg_CM_bilateral_mask.mif" -force
mrcalc "${template_dir}/amyg_CM_bilateral_mask.mif" 0 -gt "${template_dir}/amyg_CM_bilateral_mask_bin.mif" -force
# Amygdala - LB
mrcalc "${template_dir}/julich_mpm_3.0.mif" 1066 -eq "${template_dir}/amyg_LB_right_mask.mif" -force
mrcalc "${template_dir}/julich_mpm_3.0.mif" 66 -eq "${template_dir}/amyg_LB_left_mask.mif" -force  
mrcalc "${template_dir}/amyg_LB_right_mask.mif" "${template_dir}/amyg_LB_left_mask.mif" -add "${template_dir}/amyg_LB_bilateral_mask.mif" -force
mrcalc "${template_dir}/amyg_LB_bilateral_mask.mif" 0 -gt "${template_dir}/amyg_LB_bilateral_mask_bin.mif" -force
# Amygdala - SF
mrcalc "${template_dir}/julich_mpm_3.0.mif" 1065 -eq "${template_dir}/amyg_SF_right_mask.mif" -force
mrcalc "${template_dir}/julich_mpm_3.0.mif" 65 -eq "${template_dir}/amyg_SF_left_mask.mif" -force  
mrcalc "${template_dir}/amyg_SF_right_mask.mif" "${template_dir}/amyg_SF_left_mask.mif" -add "${template_dir}/amyg_SF_bilateral_mask.mif" -force
mrcalc "${template_dir}/amyg_SF_bilateral_mask.mif" 0 -gt "${template_dir}/amyg_SF_bilateral_mask_bin.mif" -force
# Amygdala CM,LB,SF
mrcalc \
  "${template_dir}/amyg_CM_bilateral_mask_bin.mif" \
  "${template_dir}/amyg_LB_bilateral_mask_bin.mif" -add \
  "${template_dir}/amyg_SF_bilateral_mask_bin.mif" -add \
  "${template_dir}/amyg_bilateral_mask_bin.mif" -force


# Ch 4 Bilateral
mrcalc "${template_dir}/julich_mpm_3.0.mif" 1092 -eq "${template_dir}/ch4_right_mask.mif" -force
mrcalc "${template_dir}/julich_mpm_3.0.mif" 92 -eq "${template_dir}/ch4_left_mask.mif" -force  
mrcalc "${template_dir}/ch4_right_mask.mif" "${template_dir}/ch4_left_mask.mif" -add "${template_dir}/Ch4_bilateral_mask.mif" -force
mrcalc "${template_dir}/ch4_bilateral_mask.mif" 0 -gt "${template_dir}/ch4_bilateral_mask_bin.mif" -force


# === Transform Atlas Masks to Subject Space ===
echo "----------------- Subject-level Registration -----------------"
for subject in $(cat "$subjects_list"); do
  echo "Registering masks for subject: $subject"

  subject_dir="$data_directory/derivatives/MRtrix3/${subject}/dwi"
  tract_dir="$subject_dir/tracts_ch4_to_amyg"
  fod="$subject_dir/${subject}_wmfod_norm.mif"
  warp_dir="$template_dir/warps"
  template_warp="$warp_dir/${subject}_wmfod_norm.mif"
  mkdir -p "$subject_dir/tracts_ch4_to_amyg"

  mrtransform -linear "$template_dir/wmfod_template_2_MNI.txt" -inverse "${template_dir}/amyg_bilateral_mask_bin.mif" "$template_dir/amyg_in_template_space.mif" -template "$template_dir/wmfod_template.mif" -interp nearest -datatype bit -force
  mrtransform -warp_full "$template_warp" -from 2 "$template_dir/amyg_in_template_space.mif" "$subject_dir/amyg_in_subject_space.mif" -template "$fod" -interp nearest -datatype bit -force
  mrtransform -linear "$template_dir/linear_transforms/${subject}_wmfod_norm.txt" -inverse "$subject_dir/amyg_in_subject_space.mif" "$subject_dir/amyg_in_subject_space_warped_to_template.mif" -template "$fod" -interp nearest -datatype bit -force




  mrtransform -linear "$template_dir/wmfod_template_2_MNI.txt" -inverse "${template_dir}/Ch4_bilateral_mask_bin.mif" "$template_dir/ch4_in_template_space.mif" -template "$template_dir/wmfod_template.mif" -interp nearest -datatype bit -force
  mrtransform -warp_full "$template_warp" -from 2 "$template_dir/ch4_in_template_space.mif" "$subject_dir/ch4_in_subject_space.mif" -template "$fod" -interp nearest -datatype bit -force
  mrtransform -linear "$template_dir/linear_transforms/${subject}_wmfod_norm.txt" -inverse "$subject_dir/ch4_in_subject_space.mif" "$subject_dir/ch4_in_subject_space_warped_to_template.mif" -template "$fod" -interp nearest -datatype bit -force

done 

for subject in $(cat "$subjects_list"); do
  echo "Generating whole-brain tractogram: $subject"

  subject_dir="$data_directory/derivatives/MRtrix3/${subject}/dwi"
  tract_dir="$subject_dir/tracts_ch4_to_amyg"
  fod="$subject_dir/${subject}_wmfod_norm.mif"
  warp_dir="$template_dir/warps"
  template_warp="$warp_dir/${subject}_wmfod_norm.mif"

echo " -> Filtering streamlines from Ch4 to Amyg..."
tckedit "${tract_dir}/${subject}_wholebrain.tck" \
    -include "$subject_dir/ch4_in_subject_space.mif" \
    -include "$subject_dir/amyg_in_subject_space.mif" \
    -tck_weights_in "${tract_dir}/${subject}_sift2_weights.txt" \
    -tck_weights_out "${tract_dir}/${subject}_sift2_weights_filtered_ch4_amyg.txt" \
    -ends_only \
    "${tract_dir}/${subject}_tracts_filtered_ch4_to_amyg.tck" -force
echo " -> Creating voxel-wise streamline density map..."
 tckmap "${tract_dir}/${subject}_tracts_filtered_ch4_to_amyg.tck" "${tract_dir}/${subject}_voxel_density.mif" \
         -template "${subject_dir}/${subject}_wmfod_norm.mif" \
         -tck_weights_in "${tract_dir}/${subject}_sift2_weights_filtered_ch4_amyg.txt" \
         -precise -force

done 

echo " -> Creating template-space fixel mask from Ch123-to-Hippocampus tract..."

echo " -> Extracting tract from population tractogram..."
tckedit "${template_dir}/tracks_20_million.tck" \
  -include "${template_dir}/ch4_in_template_space.mif" \
  -include "$template_dir/amyg_in_template_space.mif" \
  -ends_only \
  "$template_dir/tract_ch4_to_amyg_template.tck" -force

# 2. Create binary voxel mask from tract in template space
tckmap  "$template_dir/tract_ch4_to_amyg_template.tck" "${template_dir}/ch4_amyg_tract_mask_template.mif" \
        -template "$template_dir/wmfod_template_MNI.mif" -contrast tdi -force

# 3. Generate fixel mask from tract-restricted FOD template
rm -rf "${template_dir}/fixel_mask_ch4_to_amyg"
fod2fixel "${template_dir}/wmfod_template_MNI.mif" "${template_dir}/fixel_mask_ch4_to_amyg" \
           -mask "${template_dir}/ch4_amyg_tract_mask_template.mif" -force

# 4. Map tract to fixels to define fixel-wise density


tck2fixel "$template_dir/tract_ch4_to_amyg_template.tck" \
          "${template_dir}/fixel_mask_ch4_to_amyg" \
          "${template_dir}/fixel_mask_ch4_to_amyg_tracks" \
          "${template_dir}/template_fixel_track_density_ch4_to_amyg.mif" -force

# === Subject-level Tractography and FBC ===
echo "----------------- Running Subject-Level FBC -----------------"
for subject in $(cat "$subjects_list"); do
  echo "Processing subject: $subject"

  subject_dir="$data_directory/derivatives/MRtrix3/${subject}/dwi"
  tract_dir="$subject_dir/tracts_ch4_to_amyg"
  fod="$subject_dir/${subject}_wmfod_norm.mif"
  fd_map="$template_dir/fd/${subject}_fd.mif"
  warp="$subject_dir/${subject}_subject2template_warp.mif"
  ch4_mask="$subject_dir/ch4_in_subject_space_warped_to_template.mif" 
  amyg_mask="$subject_dir/amyg_in_subject_space_warped_to_template.mif"
  fbc_output_dir="$template_dir/FBC_ch4_to_amyg"
  mkdir -p "${subject_dir}/tracts_ch4_to_amyg/fixel_data"
  mkdir -p "$tract_dir/fixel_data_ch4_to_amyg"

 # Warp FD map to template space
mrtransform "${template_dir}/fd/${subject}_fd.mif" -warp "${subject_dir}/${subject}_subject2template_warp.mif" -template "${template_dir}/wmfod_template_MNI.mif" "${tract_dir}/${subject}_fd_in_template.mif" -force

# Warp voxel density map to template space before voxel2fixel
mrtransform "${tract_dir}/${subject}_voxel_density.mif" -warp "${subject_dir}/${subject}_subject2template_warp.mif" -template "${template_dir}/wmfod_template_MNI.mif" "${tract_dir}/${subject}_voxel_density_in_template_space.mif" -force
# === Step 6: Convert to fixel-wise streamline density ===

voxel2fixel "${subject_dir}/tracts_ch4_to_amyg/${subject}_voxel_density_in_template_space.mif" "$template_dir/fixel_mask_ch4_to_amyg" "${subject_dir}/tracts_ch4_to_amyg/fixel_data" "${subject}_streamline_density_fixel_ch4_to_amyg.mif" -force
# === Step 7: Compute mean streamline length ===
echo " -> Computing mean streamline length..."
tckstats "${tract_dir}/${subject}_tracts_filtered_ch4_to_amyg.tck" -dump lengths.txt -force
mean_length=$(awk '{ total += $1; count++ } END { printf "%.6f", total/count }' lengths.txt)

# Convert FD to fixel space
echo " -> Converting FD to fixel space..."
voxel2fixel "${tract_dir}/${subject}_fd_in_template.mif" "$template_dir/fixel_mask_ch4_to_amyg" "$tract_dir/fixel_data_ch4_to_amyg" "${subject}_fd_fixel.mif" -force


echo " -> Calculating FBC (FD × streamline density / mean length)..."
# Multiply FD × streamline density
mrcalc "$tract_dir/fixel_data_ch4_to_amyg/${subject}_fd_fixel.mif" "$tract_dir/fixel_data_ch4_to_amyg/${subject}_streamline_density_fixel.mif" -mult "$tract_dir/fixel_data_ch4_to_amyg/${subject}_numerator.mif" -force
mrcalc "$tract_dir/fixel_data_ch4_to_amyg/${subject}_numerator.mif" "$mean_length" -div "${tract_dir}/fixel_data_ch4_to_amygdala/${subject}_fbc.mif" -force

# Copy FBC map to group-level folder for fixelcfestats
cp "${tract_dir}/fixel_data/${subject}_fbc.mif" "$fbc_output_dir/${subject}_fbc.mif"

echo " Finished subject: $subject"

done

echo " All subjects processed for FBC."


echo " Starting fixelconnectivity and stats..."
# === Connectivity & stats using tract-specific fixel mask in template space ===
fixelconnectivity "$template_dir/fixel_mask_ch4_to_amyg" "$template_dir/tract_ch4_to_amyg_template.tck" "$template_dir/fixel_mask_ch4_to_amyg/connectivity.mif" -force

rm -rf "$template_dir/stats_fbc"

fbc_output_dir="$template_dir/FBC_ch4_to_amyg"
files_fbc="${data_directory}/code/files_fbc_BDNF_FI.txt"
design_matrix="${data_directory}/code/design_matrix_fbc_BDNF_FI.txt"
contrast_matrix="${data_directory}/code/contrast_matrix_fbc_BDNF_FI.txt"

cp "${template_dir}/fixel_mask_ch123_to_hipp/index.mif" "$template_dir/FBC_ch4_to_amyg/"
cp "${template_dir}/fixel_mask_ch123_to_hipp/directions.mif" "$template_dir/FBC_ch4_to_amyg/"

fixelcfestats "$fbc_output_dir" "$files_fbc" "$design_matrix" "$contrast_matrix" "$template_dir/fixel_mask_ch4_to_amyg/connectivity.mif" "$template_dir/ch4_to_amyg_stats_fbc" -nshuffles 5000 -force
