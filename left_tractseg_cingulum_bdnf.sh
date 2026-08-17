#!/bin/bash
# --- Ensure FSL and TractSeg environments are loaded ---

# Load FSL if needed
if [ -f /etc/profile.d/fsl.sh ]; then
    . /etc/profile.d/fsl.sh
fi

# Activate TractSeg Python environment
source "$HOME/envs/tractseg/bin/activate"

data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 


mkdir -p "${data_directory}/derivatives/MRtrix3/tract_TDis/CG_left"
mkdir -p "${data_directory}/derivatives/MRtrix3/tract_fixels/fd/CG_left"






 
	echo "----------------- Applying Tractseg -----------------"



mkdir -p "${data_directory}/template/tract_segmentation/tract_TDIs/CG_left"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG_left"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/CG_left"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/CG_left"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/CG_left"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG_left"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/CG_left"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/CG_left"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/CG_left"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/CG_left"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/CG_left"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/CG_left"




echo "----------------- Combine tractograms across hemispheres - Fornix -----------------"



#tckedit "${data_directory}/template/tract_segmentation/TOM_trackings/CG_left.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/CG_right.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/CG.tck"



echo "----------------- Convert tractograms to TDI maps -----------------"

tck2fixel "${data_directory}/template/tract_segmentation/TOM_trackings/CG_left.tck" "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG_left" "TDI.mif" -force

echo "----------------- Crop the whole brain fixel maps for each subject based on the obtained TDI map -----------------"


fixelcrop "${data_directory}/derivatives/MRtrix3/template/fd" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG_left/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/CG_left" -force

fixelcrop "${data_directory}/derivatives/MRtrix3/template/log_fc" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG_left/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/CG_left" -force

fixelcrop "${data_directory}/derivatives/MRtrix3/template/fdc" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG_left/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/CG_left" -force





#echo "----------------- Obtain fixel wise statistics FD -----------------"

fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/CG_left" "${data_directory}/template/tract_segmentation/TOM_trackings/CG_left.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG_left" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/CG_left" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/CG_left" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG_left" -force 

fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/CG_left" "${data_directory}/code/files_fd.txt" "${data_directory}/code/co_designmatrix.txt" "${data_directory}/code/co_contrastmatrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG_left" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/CG_left" -force





#echo "----------------- Obtain fixel wise statistics FC -----------------"

fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/CG_left" "${data_directory}/template/tract_segmentation/TOM_trackings/CG_left.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG_left" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/CG_left" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/CG_left" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG_left" -force

fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/CG_left" "${data_directory}/code/files_log_fc.txt" "${data_directory}/code/co_designmatrix.txt" "${data_directory}/code/co_contrastmatrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG_left" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/CG_left" -force


	


#echo "----------------- Obtain fixel wise statistics FDC -----------------"
	
fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/CG_left" "${data_directory}/template/tract_segmentation/TOM_trackings/CG_left.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG_left" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/CG_left" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/CG_left" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG_left" -force


fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/CG_left"  "${data_directory}/code/files_fdc.txt" "${data_directory}/code/co_designmatrix.txt" "${data_directory}/code/co_contrastmatrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG_left" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/CG_left" -force



# ====== Combined mean FD, log(FC), FDC in CG_left ======

data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 
sub_list="${data_directory}/code/sub_files.txt"

fd_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/CG_left"
logfc_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/CG_left"
fdc_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/CG_left"  

out_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/means/CG_left"
mkdir -p "$out_dir"

echo "subject,mean_fd_CG_left,mean_logfc_CG_left,mean_fdc_CG_left" \
  > "${out_dir}/CG_left_means.csv"

while read -r subject; do
  mean_fd=$(mrstats "${fd_dir}/${subject}_fd.mif"   -ignorezero -output mean -quiet)
  mean_logfc=$(mrstats "${logfc_dir}/${subject}_fc.mif" -ignorezero -output mean -quiet)
  mean_fdc=$(mrstats "${fdc_dir}/${subject}_fdc.mif" -ignorezero -output mean -quiet)

  echo "${subject},${mean_fd},${mean_logfc},${mean_fdc}" \
    >> "${out_dir}/CG_left_means.csv"
done < "$sub_list"

# ====== Combined SD FD, log(FC), FDC in CG_left ======

data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 
sub_list="${data_directory}/code/sub_files.txt"

fd_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/CG_left"
logfc_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/CG_left"
fdc_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/CG_left"

out_dir="${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/sd/CG_left"
mkdir -p "$out_dir"

# Write ONE header row
echo "subject,sd_fd_CG_left,sd_logfc_CG_left,sd_fdc_CG_left" \
  > "${out_dir}/CG_left_sd.csv"

while read -r subject; do

  sd_fd=$(mrstats "${fd_dir}/${subject}_fd.mif" -ignorezero -output std -quiet)
  sd_logfc=$(mrstats "${logfc_dir}/${subject}_fc.mif" -ignorezero -output std -quiet)
  sd_fdc=$(mrstats "${fdc_dir}/${subject}_fdc.mif" -ignorezero -output std -quiet)

  echo "${subject},${sd_fd},${sd_logfc},${sd_fdc}" \
    >> "${out_dir}/CG_left_sd.csv"

done < "$sub_list"

echo "Done: ${out_dir}/CG_left_sd.csv"