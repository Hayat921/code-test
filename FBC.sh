#!/bin/sh
data_directory="/media/hkhe451/Expansion/phd-projects/BDNF-project/BDNF_project_data"
template_dir="${data_directory}/derivatives/MRtrix3/template"
subjects_list="${data_directory}/code/subjects.txt"
atlas_file_septum="${data_directory}/??????????
atlas_file_hippocampus="${data_directory}/BN_Atlas_246_in_template_space.mif"
wmfod_template="${template_dir}/wmfod_template_MNI.mif"
fixel_mask="${template_dir}/fixel_mask"

mkdir -p "${template_dir}/fd_subjects_template_space"
mkdir -p "${template_dir}/tract_fixels"

mrmath "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" mean -axis 3 "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI_mean.mif" -force

 


mrtransform "${data_directory}/BN_Atlas_246_1mm.mif" -template "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI_mean.mif" -interp nearest "${data_directory}/BN_Atlas_246_in_template_space.mif" -force


-----------------------------------------------
"# FBC (Fibre Bundle Capacity) Calculation

# --------- Step 1: Warp each subject's FD into template space ---------
for subject in $(cat "${data_directory}/code/subjects.txt")
do
  echo "Warping FD for subject: ${subject}"

  mrtransform "${data_directory}/derivatives/MRtrix3/template/fd/${subject}_fd.mif" \
    -warp "${data_directory}/derivatives/MRtrix3/${subject}/dwi/${subject}_subject2template_warp.mif" \
    -reorient_fod no \
    -template "${data_directory}/derivatives/MRtrix3/template/wmfod_template.mif" \
    "${data_directory}/derivatives/MRtrix3/template/fd_subjects_template_space/${subject}_fd_template.mif" \
    -force
done

# --------- Step 2: Average FD maps across all subjects ---------
mrcat "${template_dir}/fd_subjects_template_space/"*_fd_template.mif -axis 3 "${template_dir}/fd_all_subjects.mif" -force

mrmath "${template_dir}/fd_all_subjects.mif" mean -axis 3 "${template_dir}/fd.mif" -force

echo "Group-average FD map created: ${template_dir}/fd.mif"

# --------- Step 3: Extract Septum and Hippocampus Masks from Atlases ---------
 #Julich Brain Atlas - Left Ch123

 Julich_Atlas= "${data_directory}/JulichBrainAtlas_3.0_areas_MPM_b_N10_nlin2ICBM152asym2009c_public_11035603b4744231e17e87fd8ebcaf1a.nii"

#Right Ch123 

mrconvert "Julich_Atlas" " julich_mpm_3.0.mif" -force

fsleyes "$FSLDIR/data/standard/MNI152_T1_1mm.nii.gz" JulichBrainAtlas_3.0_areas_MPM_b_N10_nlin2ICBM152asym2009c_public_11035603b4744231e17e87fd8ebcaf1a.nii

#Once FSLEYES was open I put in the coordinates of the right basal forebrain (Ch 123) and found the label index according to the atlas (1097)
mrcalc ' julich_mpm_3.0.mif' 1097 -eq ch123_right_mask.mif -force #This command created a binary mask of the right basal forebrain where voxels labeled 1097 (Ch123) were set to 1

mrview "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" -overlay.load ch123_right_mask.mif

 #Left Ch123

mrcalc ' julich_mpm_3.0.mif' 97 -eq ch123_left_mask.mif -force     

mrview "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" -overlay.load ch123_left_mask.mif

#Combinging the two masks to create a single mask for Ch123 

mrcalc ch123_left_mask.mif ch123_right_mask.mif -add ch123_bilateral_mask.mif -force

mrcalc ch123_bilateral_mask.mif 0 -gt ch123_bilateral_mask_bin.mif -force

mrview "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" -overlay.load ch123_bilateral_mask_bin.mif

#Extract Hippocampus Masks

hip_rostral_L=215
hip_caudal_L=217
hip_rostral_R=216
hip_caudal_R=218


mrcalc "$atlas_file_hippocampus" $hip_rostral_L -eq "$atlas_file_hippocampus" $hip_caudal_L -eq -add 0 -gt "${template_dir}/HippocampusLeft_mask.mif" -force
mrcalc "$atlas_file_hippocampus" $hip_rostral_R -eq "$atlas_file_hippocampus" $hip_caudal_R -eq -add 0 -gt "${template_dir}/HippocampusRight_mask.mif" -force
mrcalc "${template_dir}/HippocampusLeft_mask.mif" "${template_dir}/HippocampusRight_mask.mif" -add 0 -gt "${template_dir}/Hippocampus_mask.mif" -force

echo "Ch123 and Hippocampus masks extracted."

# --------- Step 4: Perform Tractography ---------

  tckgen "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" \
  -seed_image "${data_directory}/derivatives/MRtrix3/template/template_mask.mif" \
  -algorithm iFOD2 \
  -select 10000000 \
  -cutoff 0.06 \
  -minlength 10 \
  -maxlength 250 \
  "${data_directory}/derivatives/MRtrix3/template/global_tractography.tck" \
  -force
  
  
# --------- Step 5: Run SIFT2 on the Whole-Brain Tractogram ---------

tcksift2 "${data_directory}/derivatives/MRtrix3/template/global_tractography.tck" \
         "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" \
         "${data_directory}/derivatives/MRtrix3/template/sift2_weights.txt" \
         -force


# --------- Step 6: Filter Tractography to include only tracts between endpoints ---------

tckedit "${data_directory}/derivatives/MRtrix3/template/global_tractography.tck" \
  -include "${data_directory}/ch123_bilateral_mask_bin.mif" \
  -include "${data_directory}/derivatives/MRtrix3/template/Hippocampus_mask.mif" \
  -tck_weights_in "${data_directory}/derivatives/MRtrix3/template/sift2_weights.txt" \
  -maxweight 1.0 \
  -minweight 0.8 \
  -tck_weights_out "${data_directory}/derivatives/MRtrix3/template/sift2_weights_filtered.txt" \
  -ends_only \
  "${data_directory}/derivatives/MRtrix3/template/tract_ch123_to_hippocampus_filtered.tck" \
  -force

mrview "${data_directory}/derivatives/MRtrix3/template/wmfod_template_MNI.mif" \
  -tractography.load "${data_directory}/derivatives/MRtrix3/template/tract_ch123_to_hippocampus_filtered.tck" \
  -overlay.load "${data_directory}/ch123_bilateral_mask_bin.mif" \
  -overlay.load "${data_directory}/derivatives/MRtrix3/template/Hippocampus_mask.mif"


echo "Filtered tractography to include only endpoints."

# --------- Step 5: Map streamlines to fixels ---------
tck2fixel "${template_dir}/tract_ch123_to_hippocampus_filtered.tck" \
          "$fixel_mask" \
          "${template_dir}/tract_fixels" \
          "${template_dir}/tract_fixels/streamline_density.mif" \
          -force

echo "Streamlines mapped to fixels."

# --------- Step 6: Multiply FD × streamline density = True FBC ---------
mrcalc "${template_dir}/fd.mif" "${template_dir}/tract_fixels/streamline_density.mif" -mult \
       "${template_dir}/tract_fixels/FBC_septum_hippocampus.mif" \
       -force

echo "FBC (Fibre Bundle Capacity) calculated."

# --------- Step 7: Extract Mean FBC value ---------
mrstats "${template_dir}/tract_fixels/FBC_septum_hippocampus.mif" \
        -mask "${template_dir}/tract_fixels/streamline_density.mif" \
        -output mean > "${template_dir}/tract_fixels/mean_FBC_value.txt"

echo "Mean FBC extracted. Check file: ${template_dir}/tract_fixels/mean_FBC_value.txt"

# --------- Step 8: Visualize FBC map ---------
mrview "$wmfod_template" \
  -fixel.load "${template_dir}/tract_fixels" \
  -fixel.metric "${template_dir}/tract_fixels/FBC_septum_hippocampus.mif" \
  -fixel.display_threshold 0.01

echo " Full FBC pipeline complete!"




