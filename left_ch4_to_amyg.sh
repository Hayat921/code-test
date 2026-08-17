#!/bin/sh

# --- Make FSL visible in non-login shells ---
# Try the global profile first:
if [ -r /etc/profile.d/fsl.sh ]; then
  . /etc/profile.d/fsl.sh
fi


# === Directories and Variables ===
data_directory="/media/hkhe451/Expansion/phd-projects/test_data"
template_dir="${data_directory}/derivatives/MRtrix3/template"
subjects_list="${data_directory}/code/sub_files.txt"
Julich_Atlas="${data_directory}/JulichBrainAtlas_3.0_areas_MPM_b_N10_nlin2ICBM152asym2009c_public_11035603b4744231e17e87fd8ebcaf1a.nii"
mkdir -p "$template_dir/left_FBA_ch4"
mkdir -p "$template_dir/left_ch4_to_amyg_stats/"
mkdir -p "${template_dir}/left_ch4_to_amyg_stats/means"
mkdir -p "${template_dir}/left_ch4_to_amyg_stats/stds"


# Convert atlas
mrconvert "$Julich_Atlas" "${template_dir}/julich_mpm_3.0.mif" -force

# Individual left amygdala subnuclei (already binary after -eq)
mrcalc "${template_dir}/julich_mpm_3.0.mif" 101 -eq "${template_dir}/amyg_CM_left_mask.mif" -force   # CM
mrcalc "${template_dir}/julich_mpm_3.0.mif"  66 -eq "${template_dir}/amyg_LB_left_mask.mif" -force   # LB
mrcalc "${template_dir}/julich_mpm_3.0.mif"  65 -eq "${template_dir}/amyg_SF_left_mask.mif" -force   # SF

# Combine CM+LB+SF and binarise
mrcalc \
  "${template_dir}/amyg_CM_left_mask.mif" \
  "${template_dir}/amyg_LB_left_mask.mif" -add \
  "${template_dir}/amyg_SF_left_mask.mif" -add \
  0 -gt "${template_dir}/amyg_left_mask_bin.mif" -force

# Ch4 left (already binary after -eq)
mrcalc "${template_dir}/julich_mpm_3.0.mif" 92 -eq "${template_dir}/ch4_left_mask_bin.mif" -force




  tckedit "$template_dir/tracks_2_million_sift.tck" \
      -include "${template_dir}/ch4_left_mask_bin.mif" \
      -include "${template_dir}/amyg_left_mask_bin.mif" \
      -ends_only \
      "$template_dir/left_FBA_ch4/left_tract_ch4_to_amyg_template.tck" -force
 
 tck2fixel "$template_dir/left_FBA_ch4/left_tract_ch4_to_amyg_template.tck" "$template_dir/fixel_mask" "$template_dir/left_FBA_ch4/left_fixel_tract_ch4_to_amyg" "tdi_ch4_to_amyg.mif" -force

 mrthreshold "$template_dir/left_FBA_ch4/left_fixel_tract_ch4_to_amyg/tdi_ch4_to_amyg.mif" "${template_dir}/left_FBA_ch4/left_fixel_tract_ch4_to_amyg/mask_bin.mif" -abs 1 -force

data_directory="/media/hkhe451/Expansion/phd-projects/test_data"
      design_matrix="${data_directory}/code/test_design_matrix.txt"
     contrast_matrix="${data_directory}/code/test_contrast_matrix.txt"
     subject_list_fd="${data_directory}/code/files_fd.txt"
     subject_list_log_fc="${data_directory}/code/files_log_fc.txt"
     subject_list_fdc="${data_directory}/code/files_fdc.txt"
     template_dir="${data_directory}/derivatives/MRtrix3/template"


 #FD 
fixelcfestats "$template_dir/fd_smooth" "$subject_list_fd" "$design_matrix" "$contrast_matrix" "$template_dir/matrix" "$template_dir/left_ch4_to_amyg_stats/stats_fd_ch4_amyg" -mask "$template_dir/left_FBA_ch4/left_fixel_tract_ch4_to_amyg/mask_bin.mif" -nshuffles 5000 -force

#Log FC
fixelcfestats "$template_dir/log_fc_smooth"  "$subject_list_log_fc" "$design_matrix" "$contrast_matrix" "$template_dir/matrix" "$template_dir/left_ch4_to_amyg_stats/stats_log_fc_ch4_amyg" -mask "$template_dir/left_FBA_ch4/left_fixel_tract_ch4_to_amyg/mask_bin.mif" -nshuffles 5000 -force

#FDC
fixelcfestats "$template_dir/fdc_smooth" "$subject_list_fdc" "$design_matrix"  "$contrast_matrix"  "$template_dir/matrix"  "$template_dir/left_ch4_to_amyg_stats/stats_fdc_ch4_amyg"  -mask "$template_dir/left_FBA_ch4/left_fixel_tract_ch4_to_amyg/mask_bin.mif"  -nshuffles 5000 -force

echo "subject,mean_fd"     > "${template_dir}/left_ch4_to_amyg_stats/means/mean_fd_ch4_to_amyg.csv"
echo "subject,mean_logfc"  > "${template_dir}/left_ch4_to_amyg_stats/means/mean_logfc_ch4_to_amyg.csv"
echo "subject,mean_fdc"    > "${template_dir}/left_ch4_to_amyg_stats/means/mean_fdc_ch4_to_amyg.csv"

for subject in $(cat "${data_directory}/code/sub_files.txt"); do
  mean_fd=$(mrstats "${template_dir}/fd_smooth/${subject}_fd.mif" \
            -mask "${template_dir}/left_FBA_ch4/left_fixel_tract_ch4_to_amyg/mask_bin.mif" \
            -output mean -quiet)
  # Your log(FC) files live in log_fc/ and are named *_fc.mif in your script
  mean_logfc=$(mrstats "${template_dir}/log_fc_smooth/${subject}_fc.mif" \
              -mask "${template_dir}/left_FBA_ch4/left_fixel_tract_ch4_to_amyg/mask_bin.mif" \
              -output mean -quiet)
  mean_fdc=$(mrstats "${template_dir}/fdc_smooth/${subject}_fdc.mif" \
             -mask "${template_dir}/left_FBA_ch4/left_fixel_tract_ch4_to_amyg/mask_bin.mif" \
             -output mean -quiet)

  echo "${subject},${mean_fd}"    >> "${template_dir}/left_ch4_to_amyg_stats/means/mean_fd_ch4_to_amyg.csv"
  echo "${subject},${mean_logfc}" >> "${template_dir}/left_ch4_to_amyg_stats/means/mean_logfc_ch4_to_amyg.csv"
  echo "${subject},${mean_fdc}"   >> "${template_dir}/left_ch4_to_amyg_stats/means/mean_fdc_ch4_to_amyg.csv"
done

#calculate stds

echo "subject,std_fd"     > "${template_dir}/left_ch4_to_amyg_stats/stds/std_fd_ch4_to_amyg.csv"
echo "subject,std_logfc"  > "${template_dir}/left_ch4_to_amyg_stats/stds/std_logfc_ch4_to_amyg.csv"
echo "subject,std_fdc"    > "${template_dir}/left_ch4_to_amyg_stats/stds/std_fdc_ch4_to_amyg.csv"

for subject in $(cat "${data_directory}/code/sub_files.txt"); do
  std_fd=$(mrstats "${template_dir}/fd_smooth/${subject}_fd.mif" \
            -mask "${template_dir}/left_FBA_ch4/left_fixel_tract_ch4_to_amyg/mask_bin.mif" \
            -output std -quiet)
  # Your log(FC) files live in log_fc/ and are named *_fc.mif in your script
  std_logfc=$(mrstats "${template_dir}/log_fc_smooth/${subject}_fc.mif" \
              -mask "${template_dir}/left_FBA_ch4/left_fixel_tract_ch4_to_amyg/mask_bin.mif" \
              -output std -quiet)
  std_fdc=$(mrstats "${template_dir}/fdc/${subject}_fdc.mif" \
             -mask "${template_dir}/left_FBA_ch4/left_fixel_tract_ch4_to_amyg/mask_bin.mif" \
             -output std -quiet)

  echo "${subject},${std_fd}"    >> "${template_dir}/left_ch4_to_amyg_stats/stds/std_fd_ch4_to_amyg.csv"
  echo "${subject},${std_logfc}" >> "${template_dir}/left_ch4_to_amyg_stats/stds/std_logfc_ch4_to_amyg.csv"
  echo "${subject},${std_fdc}"   >> "${template_dir}/left_ch4_to_amyg_stats/stds/std_fdc_ch4_to_amyg.csv"
done