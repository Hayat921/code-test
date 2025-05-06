
#!/bin/sh
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data" 

mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files"
mkdir -p "${data_directory}/template/tract_segmentation/tract_TDIs/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/FX"
mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/FX"
#mkdir -p "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX_TDI.mif"











echo "----------------- Combine tractograms across hemispheres - Fornix -----------------"
# templatefile/tract_segmentation/TOM_trackings
# This makes the population template tck file.


tckedit "${data_directory}/template/tract_segmentation/TOM_trackings/FX_left.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/FX_right.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/FX.tck"



echo "----------------- Convert tractograms to TDI maps -----------------"

tck2fixel "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/FX.tck" "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX" "TDI.mif"

echo "----------------- Crop the whole brain fixel maps for each subject based on the obtained TDI map -----------------"


fixelcrop "${data_directory}/derivatives/MRtrix3/template/fd" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/FX" -force

fixelcrop "${data_directory}/derivatives/MRtrix3/template/log_fc" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/FX" -force

fixelcrop "${data_directory}/derivatives/MRtrix3/template/fdc" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/FX/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/FX" -force



echo "----------------- Obtain fixel wise statistics using the CFE method -----------------"


echo "----------------- Obtain fixel wise statistics FD -----------------"

fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/FX" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/FX.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/FX" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/FX" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX"

fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/FX" "${data_directory}/code/files_fd.txt" "${data_directory}/code/design_matrix.txt" "${data_directory}/code/contrast_matrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/FX"

mrthreshold "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/FX/fwe_1mpvalue.mif" -abs 0.95 "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/FX/sig_fixels_05.mif"

#mrstats "tract_fixels/fd/FX/subject_ID.mif" -mask "tract_stats/fd/FX/sig_fixels_05.mif" -output mean



#echo "----------------- Obtain fixel wise statistics FC -----------------"

fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/FX" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/FX.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/FX" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/FX" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX"

fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/FX"  "${data_directory}/code/files_fc.txt" "${data_directory}/code/design_matrix.txt" "${data_directory}/code/contrast_matrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/FX"

mrthreshold "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/FX/fwe_1mpvalue.mif" -abs 0.95 "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/FX/sig_fixels_05.mif"

#mrstats "tract_fixels/fc/FX/subject_ID.mif" -mask "tract_stats/fc/FX/sig_fixels_05.mif" -output mean
	


#echo "----------------- Obtain fixel wise statistics FDC -----------------"
	
fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/FX" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/FX.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/FX" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/FX" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX"


fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/FX"  "${data_directory}/code/files_fdc.txt" "${data_directory}/code/design_matrix.txt" "${data_directory}/code/contrast_matrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/FX" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/FX"

mrthreshold "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/FX/fwe_1mpvalue.mif" -abs 0.95 "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/FX/sig_fixels_05.mif"

#mrstats "tract_fixels/fdc/FX/subject_ID.mif" -mask "tract_stats/fdc/FX/sig_fixels_05.mi"f -output mean
