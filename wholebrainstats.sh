#!/bin/sh
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data" 

	
		
echo "----------------- Generating Fixel-Fixel Connectivity Matrix -----------------"
	
	fixelconnectivity "${data_directory}/derivatives/MRtrix3/template/fixel_mask" ${data_directory}/derivatives/MRtrix3/template/tracks_2_million_sift.tck "${data_directory}/derivatives/MRtrix3/template/matrix"
	
echo "----------------- Smoothing Fixel data -----------------"
	

	
	fixelfilter "${data_directory}/derivatives/MRtrix3/template/fd" smooth "${data_directory}/derivatives/MRtrix3/template/fd_smooth" -matrix "${data_directory}/derivatives/MRtrix3/template/matrix" -force
	fixelfilter "${data_directory}/derivatives/MRtrix3/template/log_fc" smooth "${data_directory}/derivatives/MRtrix3/template/log_fc_smooth" -matrix "${data_directory}/derivatives/MRtrix3/template/matrix"
	fixelfilter "${data_directory}/derivatives/MRtrix3/template/fdc" smooth "${data_directory}/derivatives/MRtrix3/template/fdc_smooth" -matrix "${data_directory}/derivatives/MRtrix3/template/matrix"
	
echo "----------------- Statistical Analysis of FD FC FDC -----------------"

	fixelcfestats "${data_directory}/derivatives/MRtrix3/template/fd_smooth" "${data_directory}/code/files_fd.txt" "${data_directory}/code/design_matrix.txt" "${data_directory}/code/contrast_matrix.txt" "${data_directory}/derivatives/MRtrix3/template/matrix" "${data_directory}/derivatives/MRtrix3/template/stats_fd" -force
	
	fixelcfestats "${data_directory}/derivatives/MRtrix3/template/log_fc_smooth" "${data_directory}/code/files_fc.txt" "${data_directory}/code/design_matrix.txt" "${data_directory}/code/contrast_matrix.txt" "${data_directory}/derivatives/MRtrix3/template/matrix" "${data_directory}/derivatives/MRtrix3/template/stats_log_fc"

	fixelcfestats "${data_directory}/derivatives/MRtrix3/template/fdc_smooth" "${data_directory}/code/files_fdc.txt" "${data_directory}/code/design_matrix.txt" "${data_directory}/code/contrast_matrix.txt" "${data_directory}/derivatives/MRtrix3/template/matrix" "${data_directory}/derivatives/MRtrix3/template/stats_fdc"
 
	#Ian's question: adjust threshold / slacken it to not be as tight and where is the raw DPRC data
	
	#THRESHOLD 1
	
	#mrthreshold "${data_directory}/derivatives/MRtrix3/template/stats_fd/fwe_1mpvalue.mif" -abs 0.95 "${data_directory}/derivatives/MRtrix3/template/stats_fd/sig_fixels_05.mif"
	#mrthreshold "${data_directory}/derivatives/MRtrix3/template/stats_log_fc/fwe_1mpvalue.mif" -abs 0.95 "${data_directory}/derivatives/MRtrix3/template/stats_log_fc/sig_fixels_05.mif"
	#mrthreshold "${data_directory}/derivatives/MRtrix3/template/stats_fdc/fwe_1mpvalue.mif" -abs 0.95 "${data_directory}/derivatives/MRtrix3/template/stats_fdc/sig_fixels_05.mif"

	#mrview template/wmfod_template.mif -fixel.load stats_fd/sig_fixels_05.mif -fixel.threshold 0.95
for subject in $(cat "${data_directory}/code/subjects.txt")
do 
	#mrstats "${data_directory}/derivatives/MRtrix3/template/fd_smooth/${subject}.mif" -mask stats_fd/sig_fixels_05.mif -output mean
	#mrstats "${data_directory}/derivatives/MRtrix3/template/log_fc_smooth/${subject}.mif" -mask stats_fc/sig_fixels_05.mif -output mean
	#mrstats "${data_directory}/derivatives/MRtrix3/template/fdc_smooth/${subject}.mif" -mask stats_fdc/sig_fixels_05.mif -output mean
done

	#THRESHOLD 2
	
	#mrthreshold "${data_directory}/derivatives/MRtrix3/template/stats_fd/fwe_1mpvalue.mif" -abs 0.90 "${data_directory}/derivatives/MRtrix3/template/stats_fd/sig_fixels_10.mif"
	#mrthreshold "${data_directory}/derivatives/MRtrix3/template/stats_log_fc/fwe_1mpvalue.mif" -abs 0.90 "${data_directory}/derivatives/MRtrix3/template/stats_log_fc/sig_fixels_10.mif"
	#mrthreshold "${data_directory}/derivatives/MRtrix3/template/stats_fdc/fwe_1mpvalue.mif" -abs 0.90 "${data_directory}/derivatives/MRtrix3/template/stats_fdc/sig_fixels_10.mif"

	#mrview template/wmfod_template.mif -fixel.load stats_fd/sig_fixels_10.mif -fixel.threshold 0.90

for subject in $(cat "${data_directory}/code/subjects.txt")
do
	#mrstats "${data_directory}/derivatives/MRtrix3/template/fd_smooth/${subject}.mif" -mask stats_fd/sig_fixels_10.mif -output mean
	#mrstats "${data_directory}/derivatives/MRtrix3/template/log_fc_smooth/${subject}.mif" -mask stats_fc/sig_fixels_10.mif -output mean
	#mrstats "${data_directory}/derivatives/MRtrix3/template/fdc_smooth/${subject}.mif" -mask stats_fdc/sig_fixels_10.mif -output mean
done
