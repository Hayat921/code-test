

#!/bin/bash

set -e

# --- Ensure FSL and TractSeg environments are loaded ---

# FSL (if needed)
if [ -r /etc/profile.d/fsl.sh ]; then
  . /etc/profile.d/fsl.sh
fi

# TractSeg env
source "$HOME/envs/tractseg/bin/activate"


data_directory="/media/hkhe451/Expansion/phd-projects/test_data"


mkdir -p "${data_directory}/derivatives/MRtrix3/tract_files"
mkdir -p "${data_directory}/derivatives/MRtrix3/tract_fixels"
mkdir -p "${data_directory}/derivatives/MRtrix3/tract_TDis/FX"
mkdir -p "${data_directory}/derivatives/MRtrix3/tract_fixels/fd/FX"

mkdir -p "${data_directory}/template/tract_segmentation"





	echo "----------------- Applying Tractseg -----------------"

	

sh2peaks "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" "${data_directory}/template/tract_segmentation/peaks.nii.gz"  -force


TractSeg -i "${data_directory}/template/tract_segmentation/peaks.nii.gz" -o "${data_directory}/template/tract_segmentation" --output_type "tract_segmentation"

TractSeg -i "${data_directory}/template/tract_segmentation/peaks.nii.gz" -o "${data_directory}/template/tract_segmentation/" --output_type "endings_segmentation"

TractSeg -i "${data_directory}/template/tract_segmentation/peaks.nii.gz" -o "${data_directory}/template/tract_segmentation/" --output_type "TOM"

Tracking -i "${data_directory}/template/tract_segmentation/peaks.nii.gz" -o "${data_directory}/template/tract_segmentation/" --tracking_format tck --nr_fibers 10000 



mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files"
mkdir -p "${data_directory}/template/tract_segmentation/tract_TDIs/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fd/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_log_fc/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fdc/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/FX"





echo "----------------- Combine tractograms across hemispheres - Fornix -----------------"



tckedit "${data_directory}/template/tract_segmentation/TOM_trackings/FX_left.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/FX_right.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/FX.tck" -force 



echo "----------------- Convert tractograms to TDI maps -----------------"

tck2fixel "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/FX.tck" "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX" "TDI.mif" -force

echo "----------------- Crop the whole brain fixel maps for each subject based on the obtained TDI map -----------------"


fixelcrop "${data_directory}/derivatives/MRtrix3/template/fd" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fd/FX" -force

fixelcrop "${data_directory}/derivatives/MRtrix3/template/log_fc" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_log_fc/FX" -force

fixelcrop "${data_directory}/derivatives/MRtrix3/template/fdc" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fdc/FX" -force



echo "----------------- Obtain fixel wise statistics using the CFE method ---------------"

echo "----------------- Obtain fixel wise statistics FD -----------------"

fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fd/FX" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/FX.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fd/FX" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/FX" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" -force 

fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/FX" "${data_directory}/code/files_fd.txt" "${data_directory}/code/test_design_matrix.txt" "${data_directory}/code/test_contrast_matrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/FX" -force




echo "----------------- Obtain fixel wise statistics FC -----------------"

fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_log_fc/FX" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/FX.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_log_fc/FX" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/FX" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" -force

fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/FX" "${data_directory}/code/files_log_fc.txt" "${data_directory}/code/test_design_matrix.txt" "${data_directory}/code/test_contrast_matrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/FX" -force

	


echo "----------------- Obtain fixel wise statistics FDC -----------------"
	
fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fdc/FX" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/FX.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fdc/FX" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/FX" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" -force


fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/FX"  "${data_directory}/code/files_fdc.txt" "${data_directory}/code/test_design_matrix.txt" "${data_directory}/code/test_contrast_matrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/FX" -force

sub_list="${data_directory}/code/sub_files.txt"

fd_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/FX"
logfc_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/FX"
fdc_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/FX"

# Means
out_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/means/FX"
mkdir -p "$out_dir"

echo "subject,mean_fd_fx,mean_logfc_fx,mean_fdc_fx" > "${out_dir}/fx_means.csv"

while read -r subject; do
  mean_fd=$(mrstats "${fd_dir}/${subject}_fd.mif"   -ignorezero -output mean -quiet)
  mean_logfc=$(mrstats "${logfc_dir}/${subject}_fc.mif"  -ignorezero -output mean -quiet)
  mean_fdc=$(mrstats "${fdc_dir}/${subject}_fdc.mif" -ignorezero -output mean -quiet)

  echo "${subject},${mean_fd},${mean_logfc},${mean_fdc}" >> "${out_dir}/fx_means.csv"
done < "$sub_list"

echo "Done: ${out_dir}/fx_means.csv"

# SD
out_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/sd/FX"
mkdir -p "$out_dir"

echo "subject,sd_fd_fx,sd_logfc_fx,sd_fdc_fx" > "${out_dir}/fx_sd.csv"

while read -r subject; do
  sd_fd=$(mrstats "${fd_dir}/${subject}_fd.mif"   -ignorezero -output std -quiet)
  sd_logfc=$(mrstats "${logfc_dir}/${subject}_fc.mif"  -ignorezero -output std -quiet)
  sd_fdc=$(mrstats "${fdc_dir}/${subject}_fdc.mif" -ignorezero -output std -quiet)

  echo "${subject},${sd_fd},${sd_logfc},${sd_fdc}" >> "${out_dir}/fx_sd.csv"
done < "$sub_list"

echo "Done: ${out_dir}/fx_sd.csv"
