#!/bin/bash
# --- Ensure FSL and TractSeg environments are loaded ---

# Load FSL if needed
if [ -f /etc/profile.d/fsl.sh ]; then
    . /etc/profile.d/fsl.sh
fi

# Activate TractSeg Python environment
source "$HOME/envs/tractseg/bin/activate"

data_directory="/media/hkhe451/Expansion/phd-projects/test_data"



mkdir -p "${data_directory}/derivatives/MRtrix3/tract_TDis/CG"
mkdir -p "${data_directory}/derivatives/MRtrix3/tract_fixels/fd/CG"






 
	echo "----------------- Applying Tractseg -----------------"




mkdir -p "${data_directory}/template/tract_segmentation/tract_TDIs/CG"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fd/CG"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_log_fc/CG"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fdc/CG"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/CG"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/CG"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/CG"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/CG"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/CG"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/CG"




echo "----------------- Combine tractograms across hemispheres - Fornix -----------------"



tckedit "${data_directory}/template/tract_segmentation/TOM_trackings/CG_left.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/CG_right.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/CG.tck" -force



echo "----------------- Convert tractograms to TDI maps -----------------"

tck2fixel "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/CG.tck" "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG" "TDI.mif" -force

echo "----------------- Crop the whole brain fixel maps for each subject based on the obtained TDI map -----------------"


fixelcrop "${data_directory}/derivatives/MRtrix3/template/fd" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fd/CG" -force

fixelcrop "${data_directory}/derivatives/MRtrix3/template/log_fc" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_log_fc/CG" -force

fixelcrop "${data_directory}/derivatives/MRtrix3/template/fdc" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fdc/CG" -force



echo "----------------- Obtain fixel wise statistics using the CFE method -----------------"


echo "----------------- Obtain fixel wise statistics FD -----------------"

fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fd/CG" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/CG.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fd/CG" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/CG" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" -force 

fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/CG" "${data_directory}/code/files_fd.txt" "${data_directory}/code/test_design_matrix.txt" "${data_directory}/code/test_contrast_matrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/CG" -force




#echo "----------------- Obtain fixel wise statistics FC -----------------"

fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_log_fc/CG" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/CG.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_log_fc/CG" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/CG" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" -force

fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/CG" "${data_directory}/code/files_log_fc.txt" "${data_directory}/code/test_design_matrix.txt" "${data_directory}/code/test_contrast_matrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/CG" -force


	


#echo "----------------- Obtain fixel wise statistics FDC -----------------"
	
fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fdc/CG" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/CG.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/full_fdc/CG" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/CG" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" -force


fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/CG"  "${data_directory}/code/files_fdc.txt" "${data_directory}/code/test_design_matrix.txt" "${data_directory}/code/test_contrast_matrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/CG" -force


# ====== Combined Mean FD, log(FC), FDC in CG ======

data_directory="/media/hkhe451/Expansion/phd-projects/test_data"
sub_list="${data_directory}/code/sub_files.txt"

fd_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/CG"
logfc_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/CG"
fdc_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/CG"

out_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/means/CG"
mkdir -p "$out_dir"

echo "subject,mean_fd_CG,mean_logfc_CG,mean_fdc_CG" \
  > "${out_dir}/CG_means.csv"

while read -r subject; do
  mean_fd=$(mrstats "${fd_dir}/${subject}_fd.mif"  -ignorezero -output mean -quiet)
  mean_logfc=$(mrstats "${logfc_dir}/${subject}_fc.mif" -ignorezero -output mean -quiet)
  mean_fdc=$(mrstats "${fdc_dir}/${subject}_fdc.mif" -ignorezero -output mean -quiet)

  echo "${subject},${mean_fd},${mean_logfc},${mean_fdc}" \
    >> "${out_dir}/CG_means.csv"
done < "$sub_list"

echo "Done: ${out_dir}/CG_means.csv"

# ====== Combined SD FD, log(FC), FDC in CG ======

out_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/sd/CG"
mkdir -p "$out_dir"

echo "subject,sd_fd_CG,sd_logfc_CG,sd_fdc_CG" \
  > "${out_dir}/CG_sd.csv"

while read -r subject; do
  sd_fd=$(mrstats "${fd_dir}/${subject}_fd.mif"  -ignorezero -output std -quiet)
  sd_logfc=$(mrstats "${logfc_dir}/${subject}_fc.mif" -ignorezero -output std -quiet)
  sd_fdc=$(mrstats "${fdc_dir}/${subject}_fdc.mif" -ignorezero -output std -quiet)

  echo "${subject},${sd_fd},${sd_logfc},${sd_fdc}" \
    >> "${out_dir}/CG_sd.csv"
done < "$sub_list"

echo "Done: ${out_dir}/CG_sd.csv"
