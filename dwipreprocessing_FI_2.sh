#!/bin/sh


# --- Make FSL visible in non-login shells ---
# Try the global profile first:
if [ -r /etc/profile.d/fsl.sh ]; then
  . /etc/profile.d/fsl.sh
fi

data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 

mkdir -p "${data_directory}/derivatives/MRtrix3/masks"
mkdir -p "${data_directory}/derivatives/MRtrix3/fods"
mkdir -p "${data_directory}/derivatives/MRtrix3/fd"	
mkdir -p "${data_directory}/derivatives/MRtrix3/fixels"




for subject in $(cat "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI/code/sub_files.txt")
do
 	cp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_mask_in_template_space.mif" "${data_directory}/derivatives/MRtrix3/masks/"
done


mrmath ${data_directory}/derivatives/MRtrix3/masks/*_mask_in_template_space.mif min "${data_directory}/derivatives/MRtrix3/template/template_mask.mif" 

mrgrid "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" regrid -voxel 2.0  "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI_2mm.mif" -force 

mrgrid "${data_directory}/derivatives/MRtrix3/template/template_mask.mif" regrid -voxel 2.0 "${data_directory}/derivatives/MRtrix3/template/template_mask_2mm.mif" -force

echo "----------------- FOD to FD -----------------"


	fod2fixel -mask "${data_directory}/derivatives/MRtrix3/template/template_mask_2mm.mif" -fmls_peak_value 0.06 "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI_2mm.mif" "${data_directory}/derivatives/MRtrix3/template/fixel_mask"
	

for subject in $(cat "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI/code/sub_files.txt")
do 


	mrtransform  "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_wmfod_norm.mif" -warp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" -reorient_fod no "${data_directory}/derivatives/MRtrix3/fods/${subject}_fod_in_template_space_NOT_REORIENTED.mif" 

	mrgrid "${data_directory}/derivatives/MRtrix3/fods/${subject}_fod_in_template_space_NOT_REORIENTED.mif" regrid -voxel 2.0 "${data_directory}/derivatives/MRtrix3/fods/${subject}_fod_in_template_space_NOT_REORIENTED_2mm.mif" -force

	
	fod2fixel -mask "${data_directory}/derivatives/MRtrix3/template/template_mask_2mm.mif" "${data_directory}/derivatives/MRtrix3/fods/${subject}_fod_in_template_space_NOT_REORIENTED_2mm.mif" "${data_directory}/derivatives/MRtrix3/fixels/${subject}_fixel_in_template_space_NOT_REORIENTED_2mm" -afd fd.mif 

	mrgrid "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" regrid -template "${data_directory}/derivatives/MRtrix3/template/template_mask_2mm.mif" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp_2mm.mif" -force

	
	fixelreorient "${data_directory}/derivatives/MRtrix3/fixels/${subject}_fixel_in_template_space_NOT_REORIENTED_2mm" "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp_2mm.mif" "${data_directory}/derivatives/MRtrix3/fixels/${subject}_fixel_in_template_space_reoriented_2mm" 
	
done 
	
echo "----------------- Starting to assign subject fixel to template fixels -----------------"

for subject in $(cat "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI/code/sub_files.txt")
do 


	fixelcorrespondence "${data_directory}/derivatives/MRtrix3/fixels/${subject}_fixel_in_template_space_reoriented_2mm/fd.mif" "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/derivatives/MRtrix3/template/fd" "${subject}_fd.mif" 
	
done 

echo "----------------- Computing FC  -----------------"

for subject in $(cat "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI/code/sub_files.txt")
do 


	warp2metric "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp_2mm.mif" -fc "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/derivatives/MRtrix3/template/fc" "${subject}_fc.mif" 
done 

	mkdir "${data_directory}/derivatives/MRtrix3/template/log_fc"
	
	cp "${data_directory}/derivatives/MRtrix3/template/fc/index.mif" "${data_directory}/derivatives/MRtrix3/template/fc/directions.mif" "${data_directory}/derivatives/MRtrix3/template/log_fc"
	
for subject in $(cat "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI/code/sub_files.txt")
do 
	
	mrcalc "${data_directory}/derivatives/MRtrix3/template/fc/${subject}_fc.mif" -log "${data_directory}/derivatives/MRtrix3/template/log_fc/${subject}_fc.mif"
	
done 
	
echo "----------------- Computing FDC -----------------"

mkdir "${data_directory}/derivatives/MRtrix3/template/fdc"
	
	cp "${data_directory}/derivatives/MRtrix3/template/fc/index.mif" "${data_directory}/derivatives/MRtrix3/template/fdc" 
	cp "${data_directory}/derivatives/MRtrix3/template/fc/directions.mif" "${data_directory}/derivatives/MRtrix3/template/fdc"
	
for subject in $(cat "/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI/code/sub_files.txt")
do 

	
	mrcalc "${data_directory}/derivatives/MRtrix3/template/fd/${subject}_fd.mif" "${data_directory}/derivatives/MRtrix3/template/fc/${subject}_fc.mif" -mult "${data_directory}/derivatives/MRtrix3/template/fdc/${subject}_fdc.mif"
	
done 



echo "----------------- Whole-brain fibre tractography on FOD template -----------------"	

	cd "${data_directory}/derivatives/MRtrix3/template"
	
	tckgen -angle 22.5 -maxlen 250 -minlen 10 -power 1.0 "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI_2mm.mif" -seed_image "${data_directory}/derivatives/MRtrix3/template/template_mask_2mm.mif" -select 20000000 -cutoff 0.06 tracks_20_million.tck 
	
echo "----------------- Reduce Biases in Tractogram Desnisites -----------------"
	
	tcksift tracks_20_million.tck "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI_2mm.mif" tracks_2_million_sift.tck -term_number 2000000 




data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 

	
		
echo "----------------- Generating Fixel-Fixel Connectivity Matrix -----------------"
	#mkdir "${data_directory}/derivatives/MRtrix3/template/matrix"

	fixelconnectivity "${data_directory}/derivatives/MRtrix3/template/fixel_mask" "${data_directory}/derivatives/MRtrix3/template/tracks_2_million_sift.tck" "${data_directory}/derivatives/MRtrix3/template/matrix" 
	
	
echo "----------------- Smoothing Fixel data -----------------"
	

	
	fixelfilter "${data_directory}/derivatives/MRtrix3/template/fd" smooth "${data_directory}/derivatives/MRtrix3/template/fd_smooth" -matrix "${data_directory}/derivatives/MRtrix3/template/matrix" 
	fixelfilter "${data_directory}/derivatives/MRtrix3/template/log_fc" smooth "${data_directory}/derivatives/MRtrix3/template/log_fc_smooth" -matrix "${data_directory}/derivatives/MRtrix3/template/matrix" 
	fixelfilter "${data_directory}/derivatives/MRtrix3/template/fdc" smooth "${data_directory}/derivatives/MRtrix3/template/fdc_smooth" -matrix "${data_directory}/derivatives/MRtrix3/template/matrix" 
	
echo "----------------- Statistical Analysis of FD FC FDC -----------------"

	fixelcfestats "${data_directory}/derivatives/MRtrix3/template/fd_smooth" "${data_directory}/code/files_fd.txt" "${data_directory}/code/co_designmatrix.txt" "${data_directory}/code/co_contrastmatrix.txt" "${data_directory}/derivatives/MRtrix3/template/matrix" "${data_directory}/derivatives/MRtrix3/template/stats_fd" -nshuffles 5000 -force
	
	fixelcfestats "${data_directory}/derivatives/MRtrix3/template/log_fc_smooth" "${data_directory}/code/files_log_fc.txt" "${data_directory}/code/co_designmatrix.txt" "${data_directory}/code/co_contrastmatrix.txt" "${data_directory}/derivatives/MRtrix3/template/matrix" "${data_directory}/derivatives/MRtrix3/template/stats_log_fc" -nshuffles 5000 -force

	fixelcfestats "${data_directory}/derivatives/MRtrix3/template/fdc_smooth" "${data_directory}/code/files_fdc.txt" "${data_directory}/code/co_designmatrix.txt" "${data_directory}/code/co_contrastmatrix.txt" "${data_directory}/derivatives/MRtrix3/template/matrix" "${data_directory}/derivatives/MRtrix3/template/stats_fdc" -nshuffles 5000 -force



# ====== Setup common paths ======
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_FI" 
template_dir="${data_directory}/derivatives/MRtrix3/template"
sub_list="${data_directory}/code/sub_files.txt"

#############################################
#   WHOLE-BRAIN MEAN (FD, logFC, FDC)
#############################################

mkdir -p "${template_dir}/global_means"

# Write header once
echo "subject,mean_fd_smooth,mean_logfc_smooth,mean_fdc_smooth" \
  > "${template_dir}/global_means/whole_brain_means.csv"

while read -r subject; do

  mean_fd=$(mrstats "${template_dir}/fd_smooth/${subject}_fd.mif" \
             -ignorezero -output mean -quiet)

  mean_logfc=$(mrstats "${template_dir}/log_fc_smooth/${subject}_fc.mif" \
                -ignorezero -output mean -quiet)

  mean_fdc=$(mrstats "${template_dir}/fdc_smooth/${subject}_fdc.mif" \
              -ignorezero -output mean -quiet)

  echo "${subject},${mean_fd},${mean_logfc},${mean_fdc}" \
    >> "${template_dir}/global_means/whole_brain_means.csv"

done < "$sub_list"

echo "Done: wrote whole-brain means to ${template_dir}/global_means/whole_brain_means.csv"


#############################################
#   WHOLE-BRAIN SD (FD, logFC, FDC)
#############################################

mkdir -p "${template_dir}/global_sd"

# Write header once
echo "subject,sd_fd_smooth,sd_logfc_smooth,sd_fdc_smooth" \
  > "${template_dir}/global_sd/whole_brain_sd.csv"

while read -r subject; do

  sd_fd=$(mrstats "${template_dir}/fd_smooth/${subject}_fd.mif" \
           -ignorezero -output std -quiet)

  sd_logfc=$(mrstats "${template_dir}/log_fc_smooth/${subject}_fc.mif" \
             -ignorezero -output std -quiet)

  sd_fdc=$(mrstats "${template_dir}/fdc_smooth/${subject}_fdc.mif" \
            -ignorezero -output std -quiet)

  echo "${subject},${sd_fd},${sd_logfc},${sd_fdc}" \
    >> "${template_dir}/global_sd/whole_brain_sd.csv"

done < "$sub_list"

echo "Done: wrote whole-brain SD to ${template_dir}/global_sd/whole_brain_sd.csv"

# EFFECT SIZE RELATIVE TO CONTROLS FD 

mrmath "${data_directory}/derivatives/MRtrix3/template/controls_fd_smooth"/* sum  "${data_directory}/derivatives/MRtrix3/template/control_sum_fd.mif" 

mrcalc "${data_directory}/derivatives/MRtrix3/template/control_sum_fd.mif" 31 -div  "${data_directory}/derivatives/MRtrix3/template/control_mean_fd.mif" 

mrcalc "${data_directory}/derivatives/MRtrix3/template/stats_fd/abs_effect_t2.mif" "${data_directory}/derivatives/MRtrix3/template/control_mean_fd.mif" -div 100 -mult "${data_directory}/derivatives/MRtrix3/template/stats_fd/percentage_effect_t2.mif"

#glass brain


