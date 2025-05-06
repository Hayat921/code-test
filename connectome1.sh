#!/bin/sh
data_directory="/home/hkhe451/phd-projects/BDNF-project/BDNF_project_data"
subject="sub-01"
mkdir "${data_directory}/derivatives/MRtrix3_Connectome/${subject}/"
mkdir "${data_directory}/derivatives/MRtrix3_Connectome/${subject}/con/"

mrtrix_directory="${data_directory}/derivatives/MRtrix3/${subject}"
mrtrix_connectome_directory="${data_directory}/derivatives/MRtrix3_Connectome/${subject}/con"
