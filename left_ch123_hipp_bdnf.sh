#!/bin/sh

# --- Make FSL visible in non-login shells ---
# Try the global profile first:
if [ -r /etc/profile.d/fsl.sh ]; then
  . /etc/profile.d/fsl.sh
fi


# Set directories
# === Directories and Variables ===
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 
template_dir="${data_directory}/derivatives/MRtrix3/template"
subjects_list="${data_directory}/code/sub_files.txt"
atlas_file_hippocampus="${data_directory}/BN_Atlas_246_in_template_space.mif"
Julich_Atlas="${data_directory}/JulichBrainAtlas_3.0_areas_MPM_b_N10_nlin2ICBM152asym2009c_public_11035603b4744231e17e87fd8ebcaf1a.nii"
mkdir -p "$template_dir/left_FBA_ch123"
mkdir -p "$template_dir/left_ch123_to_hipp_stats/"
mkdir -p "${template_dir}/left_ch123_to_hipp_stats/means"
mkdir -p "${template_dir}/left_ch123_to_hipp_stats/stds"

# === Generate Ch123 and Hippocampus Masks ===
mrconvert "$Julich_Atlas" "$template_dir/julich_mpm_3.0.mif" -force
mrcalc "$template_dir/julich_mpm_3.0.mif" 97 -eq "$template_dir/ch123_left_mask.mif" -force
mrcalc "$template_dir/ch123_left_mask.mif" 0 -gt "$template_dir/ch123_left_mask_bin.mif" -force

hip_rostral_L=215
hip_caudal_L=217


# Combine rostral (215) + caudal (217) left hippocampus, then binarise
mrcalc "$atlas_file_hippocampus" $hip_rostral_L -eq "$atlas_file_hippocampus" $hip_caudal_L -eq -add 0 -gt "$template_dir/HippocampusLeft_mask_bin.mif" -force

tckedit "$template_dir/tracks_2_million_sift.tck" \
      -include "$template_dir/ch123_left_mask_bin.mif" \
      -include "$template_dir/HippocampusLeft_mask_bin.mif" \
      -ends_only \
      "$template_dir/left_FBA_ch123/left_tract_ch123_to_hipp_template.tck" -force

tck2fixel "$template_dir/left_FBA_ch123/left_tract_ch123_to_hipp_template.tck" "$template_dir/fixel_mask" "$template_dir/left_FBA_ch123/fixel_tract_left_ch123_to_hipp" "tdi_ch123_to_hipp.mif" -force

mrthreshold "${template_dir}/left_FBA_ch123/fixel_tract_left_ch123_to_hipp/tdi_ch123_to_hipp.mif" "${template_dir}/left_FBA_ch123/fixel_tract_left_ch123_to_hipp/mask_bin.mif" -abs 1 -force

data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 
design_matrix="${data_directory}/code/co_designmatrix.txt"
contrast_matrix="${data_directory}/code/co_contrastmatrix.txt"
subject_list_fd="${data_directory}/code/files_fd.txt"
subject_list_log_fc="${data_directory}/code/files_log_fc.txt"
subject_list_fdc="${data_directory}/code/files_fdc.txt"
template_dir="${data_directory}/derivatives/MRtrix3/template"

#FD
fixelcfestats "$template_dir/fd_smooth" "$subject_list_fd" "$design_matrix" "$contrast_matrix" "$template_dir/matrix" "$template_dir/left_ch123_to_hipp_stats/stats_fd_ch123_hipp" -mask "$template_dir/left_FBA_ch123/fixel_tract_left_ch123_to_hipp/mask_bin.mif" -nshuffles 5000 -force

#Log FC
fixelcfestats "$template_dir/log_fc_smooth"  "$subject_list_log_fc" "$design_matrix" "$contrast_matrix" "$template_dir/matrix" "$template_dir/left_ch123_to_hipp_stats/stats_log_fc_ch123_hipp" -mask "$template_dir/left_FBA_ch123/fixel_tract_left_ch123_to_hipp/mask_bin.mif" -nshuffles 5000 -force

#FDC
fixelcfestats "$template_dir/fdc_smooth" "$subject_list_fdc" "$design_matrix"  "$contrast_matrix"  "$template_dir/matrix"  "$template_dir/left_ch123_to_hipp_stats/stats_fdc_ch123_hipp"  -mask "$template_dir/left_FBA_ch123/fixel_tract_left_ch123_to_hipp/mask_bin.mif"  -nshuffles 5000 -force


# === Per-subject means ===
echo "subject,mean_fd"    > "${template_dir}/left_ch123_to_hipp_stats/means/mean_fd_ch123_to_hipp.csv"
echo "subject,mean_logfc" > "${template_dir}/left_ch123_to_hipp_stats/means/mean_logfc_ch123_to_hipp.csv"
echo "subject,mean_fdc"   > "${template_dir}/left_ch123_to_hipp_stats/means/mean_fdc_ch123_to_hipp.csv"

while read -r subject; do
  mean_fd=$(mrstats "${template_dir}/fd_smooth/${subject}_fd.mif" \
            -mask "${template_dir}/left_FBA_ch123/fixel_tract_left_ch123_to_hipp/mask_bin.mif" \
            -output mean -quiet)

  mean_logfc=$(mrstats "${template_dir}/log_fc_smooth/${subject}_fc.mif" \
              -mask "${template_dir}/left_FBA_ch123/fixel_tract_left_ch123_to_hipp/mask_bin.mif" \
              -output mean -quiet)

  mean_fdc=$(mrstats "${template_dir}/fdc_smooth/${subject}_fdc.mif" \
             -mask "${template_dir}/left_FBA_ch123/fixel_tract_left_ch123_to_hipp/mask_bin.mif" \
             -output mean -quiet)

  echo "${subject},${mean_fd}"    >> "${template_dir}/left_ch123_to_hipp_stats/means/mean_fd_ch123_to_hipp.csv"
  echo "${subject},${mean_logfc}" >> "${template_dir}/left_ch123_to_hipp_stats/means/mean_logfc_ch123_to_hipp.csv"
  echo "${subject},${mean_fdc}"   >> "${template_dir}/left_ch123_to_hipp_stats/means/mean_fdc_ch123_to_hipp.csv"
done < "$subjects_list"

# === Per-subject SDs ===
echo "subject,std_fd"    > "${template_dir}/left_ch123_to_hipp_stats/stds/std_fd_ch123_to_hipp.csv"
echo "subject,std_logfc" > "${template_dir}/left_ch123_to_hipp_stats/stds/std_logfc_ch123_to_hipp.csv"
echo "subject,std_fdc"   > "${template_dir}/left_ch123_to_hipp_stats/stds/std_fdc_ch123_to_hipp.csv"

while read -r subject; do
  std_fd=$(mrstats "${template_dir}/fd_smooth/${subject}_fd.mif" \
           -mask "${template_dir}/left_FBA_ch123/fixel_tract_left_ch123_to_hipp/mask_bin.mif" \
           -output std -quiet)

  std_logfc=$(mrstats "${template_dir}/log_fc_smooth/${subject}_fc.mif" \
             -mask "${template_dir}/left_FBA_ch123/fixel_tract_left_ch123_to_hipp/mask_bin.mif" \
             -output std -quiet)

  std_fdc=$(mrstats "${template_dir}/fdc_smooth/${subject}_fdc.mif" \
            -mask "${template_dir}/left_FBA_ch123/fixel_tract_left_ch123_to_hipp/mask_bin.mif" \
            -output std -quiet)

  echo "${subject},${std_fd}"    >> "${template_dir}/left_ch123_to_hipp_stats/stds/std_fd_ch123_to_hipp.csv"
  echo "${subject},${std_logfc}" >> "${template_dir}/left_ch123_to_hipp_stats/stds/std_logfc_ch123_to_hipp.csv"
  echo "${subject},${std_fdc}"   >> "${template_dir}/left_ch123_to_hipp_stats/stds/std_fdc_ch123_to_hipp.csv"
done < "$subjects_list"