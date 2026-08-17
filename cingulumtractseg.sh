#!/bin/sh
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data" 


echo "----------------- Combine tractograms across hemispheres - Cingulum -----------------"
# templatefile/tract_segmentation/TOM_trackings
# This makes the population template tck file.


tckedit "${data_directory}/template/tract_segmentation/TOM_trackings/CG_left.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/CG_right.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/CG.tck"



echo "----------------- Convert tractograms to TDI maps -----------------"

tck2fixel "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/CG.tck" "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG" "TDI.mif"

echo "----------------- Crop the whole brain fixel maps for each subject based on the obtained TDI map -----------------"


fixelcrop "${data_directory}/derivatives/MRtrix3/template/fd" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/CG" -force

fixelcrop "${data_directory}/derivatives/MRtrix3/template/log_fc" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/CG" -force

fixelcrop "${data_directory}/derivatives/MRtrix3/template/fdc" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_TDIs/CG/TDI.mif" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/CG" -force



echo "----------------- Obtain fixel wise statistics using the CFE method -----------------"


echo "----------------- Obtain fixel wise statistics FD -----------------"

fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/CG" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/CG.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fd/CG" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/CG" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG"

fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fd/CG" "${data_directory}/code/files_fd.txt" "${data_directory}/code/design_matrix.txt" "${data_directory}/code/contrast_matrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/CG"

mrthreshold "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/CG/fwe_1mpvalue.mif" -abs 0.95 "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fd/CG/sig_fixels_05.mif"

#mrstats "tract_fixels/fd/CG/subject_ID.mif" -mask "tract_stats/fd/CG/sig_fixels_05.mif" -output mean



#echo "----------------- Obtain fixel wise statistics FC -----------------"

fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/CG" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/CG.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/log_fc/CG" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/CG" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG"

fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/log_fc/CG"  "${data_directory}/code/files_fc.txt" "${data_directory}/code/design_matrix.txt" "${data_directory}/code/contrast_matrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/CG"

mrthreshold "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/CG/fwe_1mpvalue.mif" -abs 0.95 "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fc/CG/sig_fixels_05.mif"

#mrstats "tract_fixels/fc/CG/subject_ID.mif" -mask "tract_stats/fc/CG/sig_fixels_05.mif" -output mean
	


#echo "----------------- Obtain fixel wise statistics FDC -----------------"
	
fixelconnectivity "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/CG" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_files/CG.tck" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" -force

fixelfilter "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels/fdc/CG" smooth "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/CG" -matrix "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG"


fixelcfestats "${data_directory}/template/tract_segmentation/TOM_trackings/tract_fixels_smoothed/fdc/CG"  "${data_directory}/code/files_fdc.txt" "${data_directory}/code/design_matrix.txt" "${data_directory}/code/contrast_matrix.txt" "${data_directory}/template/tract_segmentation/TOM_trackings/matrix/CG" "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/CG"

mrthreshold "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/CG/fwe_1mpvalue.mif" -abs 0.95 "${data_directory}/template/tract_segmentation/TOM_trackings/tract_stats/fdc/CG/sig_fixels_05.mif"

