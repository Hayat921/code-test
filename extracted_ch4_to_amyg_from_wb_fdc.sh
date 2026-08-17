#!/bin/bash

# === Directories and Variables ===
data_directory=/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI
template_dir="${data_directory}/derivatives/MRtrix3/template"
subjects_list="${data_directory}/code/sub_files.txt"
Julich_Atlas="${data_directory}/JulichBrainAtlas_3.0_areas_MPM_b_N10_nlin2ICBM152asym2009c_public_11035603b4744231e17e87fd8ebcaf1a.nii"
FBA_ch4="${data_directory}/derivatives/MRtrix3/template/FBA_ch4"
mkdir -p "$template_dir/FBA_ch4"
mkdir -p "$template_dir/ch4_to_amyg_stats/"
mkdir -p "$template_dir/ch4_to_amyg_stats/means/"



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

      
      tckedit "$template_dir/tracks_2_million_sift.tck" \
      -include "${template_dir}/ch4_bilateral_mask_bin.mif" \
      -include "${template_dir}/amyg_bilateral_mask_bin.mif" \
      -ends_only \
      "$template_dir/FBA_ch4/tract_ch4_to_amyg_template.tck" -force


       tck2fixel "$template_dir/FBA_ch4/tract_ch4_to_amyg_template.tck" "$template_dir/fixel_mask" "$template_dir/FBA_ch4/fixel_tract_ch4_to_amyg" "tdi_ch4_to_amyg.mif" -force

       #tckmap "$template_dir/FBA_ch4/tract_ch4_to_amyg_template.tck" "$template_dir/tract_mask_template.mif" -template "$template_dir/wmfod_template_MNI.mif" -tck_weights_in "$template_dir/FBA_ch4/tract_ch4_to_hipp_weights.txt" -contrast tdi -force
        mrthreshold "$template_dir/FBA_ch4/fixel_tract_ch4_to_amyg/tdi_ch4_to_amyg.mif" "${template_dir}/FBA_ch4/fixel_tract_ch4_to_amyg/mask_bin.mif" -abs 1 -force

       #mrcalc "$template_dir/FBA_ch4/fixel_tract_ch4_to_amyg/fd.mif" 0.01 -gt "$template_dir/FBA_ch4/fixel_tract_ch4_to_amyg/mask_bin.mif" -force

      
      
     data_directory=/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI
     design_matrix="${data_directory}/code/1intercept_designmatrix.txt"
     contrast_matrix="${data_directory}/code/0intercept_contrastmatrix.txt"
     subject_list_fd="${data_directory}/code/files_fd.txt"
     subject_list_log_fc="${data_directory}/code/files_log_fc.txt"
     subject_list_fdc="${data_directory}/code/files_fdc.txt"





template_dir="${data_directory}/derivatives/MRtrix3/template"


 #FD 
fixelcfestats "$template_dir/fd_smooth" "$subject_list_fd" "$design_matrix" "$contrast_matrix" "$template_dir/matrix" "$template_dir/ch4_to_amyg_stats/stats_fd_ch4_amyg" -mask "$template_dir/FBA_ch4/fixel_tract_ch4_to_amyg/mask_bin.mif" -nshuffles 5000 -force

#Log FC
fixelcfestats "$template_dir/log_fc_smooth"  "$subject_list_log_fc" "$design_matrix" "$contrast_matrix" "$template_dir/matrix" "$template_dir/ch4_to_amyg_stats/stats_log_fc_ch4_amyg" -mask "$template_dir/FBA_ch4/fixel_tract_ch4_to_amyg/mask_bin.mif" -nshuffles 5000 -force

#FDC
fixelcfestats "$template_dir/fdc_smooth" "$subject_list_fdc" "$design_matrix"  "$contrast_matrix"  "$template_dir/matrix"  "$template_dir/ch4_to_amyg_stats/stats_fdc_ch4_amyg"  -mask "$template_dir/FBA_ch4/fixel_tract_ch4_to_amyg/mask_bin.mif"  -nshuffles 5000 -force



echo "subject,mean_fd"     > "${template_dir}/ch4_to_amyg_stats/means/mean_fd_ch4_to_amyg.csv"
echo "subject,mean_logfc"  > "${template_dir}/ch4_to_amyg_stats/means/mean_logfc_ch4_to_amyg.csv"
echo "subject,mean_fdc"    > "${template_dir}/ch4_to_amyg_stats/means/mean_fdc_ch4_to_amyg.csv"

for subject in $(cat "${data_directory}/code/sub_files.txt"); do
  mean_fd=$(mrstats "${template_dir}/fd/${subject}_fd.mif" \
            -mask "${template_dir}/FBA_ch4/fixel_tract_ch4_to_amyg/mask_bin.mif" \
            -output mean -quiet)
  # Your log(FC) files live in log_fc/ and are named *_fc.mif in your script
  mean_logfc=$(mrstats "${template_dir}/log_fc/${subject}_fc.mif" \
              -mask "${template_dir}/FBA_ch4/fixel_tract_ch4_to_amyg/mask_bin.mif" \
              -output mean -quiet)
  mean_fdc=$(mrstats "${template_dir}/fdc/${subject}_fdc.mif" \
             -mask "${template_dir}/FBA_ch4/fixel_tract_ch4_to_amyg/mask_bin.mif" \
             -output mean -quiet) 

  printf "%s,%s\n" "$subject" "$mean_fd"    >> "${template_dir}/ch4_to_amyg_stats/means/mean_fd_ch4_to_amyg.csv"  
  printf "%s,%s\n" "$subject" "$mean_logfc" >> "${template_dir}/ch4_to_amyg_stats/means/mean_logfc_ch4_to_amyg.csv" 
  printf "%s,%s\n" "$subject" "$mean_fdc"   >> "${template_dir}/ch4_to_amyg_stats/means/mean_fdc_ch4_to_amyg.csv" 

done