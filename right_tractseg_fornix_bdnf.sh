#!/bin/bash
# --- Ensure FSL and TractSeg environments are loaded ---

# Load FSL if needed
if [ -f /etc/profile.d/fsl.sh ]; then
    . /etc/profile.d/fsl.sh
fi

# Activate TractSeg Python environment
source "$HOME/envs/tractseg/bin/activate"

data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 

mkdir -p "${data_directory}/derivatives/MRtrix3/tract_files"
mkdir -p "${data_directory}/derivatives/MRtrix3/tract_fixels"
mkdir -p "${data_directory}/derivatives/MRtrix3/tract_TDis/FX_right"
mkdir -p "${data_directory}/derivatives/MRtrix3/tract_fixels/fd/FX_right"

mkdir -p "${data_directory}/template/tract_segmentation"




	echo "----------------- Applying Tractseg -----------------"




mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files"
mkdir -p "${data_directory}/template/tract_segmentation/tract_TDIs/FX_right"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX_right"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/FX_right"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/FX_right"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/FX_right"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX_right"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/FX_right"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/FX_right"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/FX_right"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/FX_right"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/FX_right"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/FX_right"
#mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX_TDI.mif"




echo "----------------- Combine tractograms across hemispheres - Fornix -----------------"
# templatefile/tract_segmentation/TOM_trackings
# This makes the population template tck file.


#tckedit "${data_directory}/template/tract_segmentation/TOM_trackings/FX_left.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/FX_right.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/FX.tck"



echo "----------------- Convert tractograms to TDI maps -----------------"

tck2fixel "${data_directory}/template/tract_segmentation/TOM_trackings/FX_right.tck" "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX_right" "TDI.mif" -force

echo "----------------- Crop the whole brain fixel maps for each subject based on the obtained TDI map -----------------"


fixelcrop "${data_directory}/derivatives/MRtrix3/template/fd" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX_right/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/FX_right" -force

fixelcrop "${data_directory}/derivatives/MRtrix3/template/log_fc" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX_right/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/FX_right" -force

fixelcrop "${data_directory}/derivatives/MRtrix3/template/fdc" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX_right/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/FX_right" -force



echo "----------------- Obtain fixel wise statistics using the CFE method -----------------"


echo "----------------- Obtain fixel wise statistics FD -----------------"

fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/FX_right" "${data_directory}/template/tract_segmentation/TOM_trackings/FX_right.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX_right" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/FX_right" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/FX_right" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX_right" -force 

fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/FX_right" "${data_directory}/code/files_fd.txt" "${data_directory}/code/co_designmatrix.txt" "${data_directory}/code/co_contrastmatrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX_right" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/FX_right" -force




#echo "----------------- Obtain fixel wise statistics FC -----------------"

fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/FX_right" "${data_directory}/template/tract_segmentation/TOM_trackings/FX_right.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX_right" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/FX_right" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/FX_right" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX_right" -force

fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/FX_right" "${data_directory}/code/files_log_fc.txt" "${data_directory}/code/co_designmatrix.txt" "${data_directory}/code/co_contrastmatrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX_right" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/FX_right" -force


	


#echo "----------------- Obtain fixel wise statistics FDC -----------------"
	
fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/FX_right" "${data_directory}/template/tract_segmentation/TOM_trackings/FX_right.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX_right" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/FX_right" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/FX_right" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX_right" -force


fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/FX_right"  "${data_directory}/code/files_fdc.txt" "${data_directory}/code/co_designmatrix.txt" "${data_directory}/code/co_contrastmatrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX_right" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/FX_right" -force


# ====== Combined mean FD, log(FC), FDC in FX_right ======

data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 
sub_list="${data_directory}/code/sub_files.txt"

fd_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/FX_right"
logfc_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/FX_right"
fdc_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/FX_right"

out_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/means/FX_right"
mkdir -p "$out_dir"

# Write ONE header row
echo "subject,mean_fd_FX_right,mean_logfc_FX_right,mean_fdc_FX_right" \
  > "${out_dir}/FX_right_means.csv"

while read -r subject; do

  mean_fd=$(mrstats "${fd_dir}/${subject}_fd.mif" -ignorezero -output mean -quiet)
  mean_logfc=$(mrstats "${logfc_dir}/${subject}_fc.mif" -ignorezero -output mean -quiet)
  mean_fdc=$(mrstats "${fdc_dir}/${subject}_fdc.mif" -ignorezero -output mean -quiet)

  echo "${subject},${mean_fd},${mean_logfc},${mean_fdc}" \
    >> "${out_dir}/FX_right_means.csv"

done < "$sub_list"

echo "Done: ${out_dir}/FX_right_means.csv"

# ====== Combined SD FD, log(FC), FDC in FX_right ======

data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 
sub_list="${data_directory}/code/sub_files.txt"

fd_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/FX_right"
logfc_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/FX_right"
fdc_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/FX_right"

out_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/sd/FX_right"
mkdir -p "$out_dir"


echo "subject,sd_fd_fx_right,sd_logfc_fx_right,sd_fdc_fx_right" > "${out_dir}/fx_right_sd.csv"

while read -r subject; do
  sd_fd=$(mrstats "${fd_dir}/${subject}_fd.mif"   -ignorezero -output std -quiet)
  sd_logfc=$(mrstats "${logfc_dir}/${subject}_fc.mif"  -ignorezero -output std -quiet)
  sd_fdc=$(mrstats "${fdc_dir}/${subject}_fdc.mif" -ignorezero -output std -quiet)

  echo "${subject},${sd_fd},${sd_logfc},${sd_fdc}" >> "${out_dir}/fx_right_sd.csv"
done < "$sub_list"

echo "Done: ${out_dir}/fx_right_sd.csv"
