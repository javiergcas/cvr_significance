#!/bash/sh
set -e

echo "++ INFO: Loading python environment ...."
source /data/SFIMJGC_HCP7T/Apps/miniconda38/etc/profile.d/conda.sh && conda activate bcbl_visit

REST_INPUT=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/${SBJ}/${SBJ}_ants_transformed-MNI_REST-ICs.2p5mm_iso.txt`
BH_INPUT=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/${SBJ}/${SBJ}_${SES}_ants_transformed-MNI_CVR-ICs.2p5mm_iso.txt`
OUTPUT_PATH=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/${SBJ}/burton2020/${SBJ}_REST-IC-${REST_IC}_vs_BH_${SES}.txt`
REST_SURROGATES=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/${SBJ}/burton2020/${SBJ}_ants_transformed-MNI_REST-ICs.2p5mm_iso.comp_${REST_IC}.surrogate_maps.npy`
echo "REST_INPUT = ${REST_INPUT}"
echo "BH_INPUT = ${BH_INPUT}"
echo "OUTPUT_PATH = ${OUTPUT_PATH}"
echo "REST_SURROGATES = ${REST_SURROGATES}"

python /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/code/python/run_compare_images.py \
       -rest_input ${REST_INPUT} \
       -bh_input   ${BH_INPUT} \
       -rest_surrogates ${REST_SURROGATES} \
       -output_path ${OUTPUT_PATH} \
       -rest_ic ${REST_IC} \
       -metric pearsonr

echo "++ INFO: Program finished succesfully --> outputs in ${OUTPUT_PATH}"
