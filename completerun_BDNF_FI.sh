#!/bin/sh

./dwipreprocessing_FI_1.sh 
./dwipreprocessing_FI_2.sh
./extracted_ch123_to_hipp_from_wb_fdc.sh
./extracted_ch4_to_amyg_from_wb_fdc.sh
./tractseg_fornix.sh
./tractseg_cingulum.sh
