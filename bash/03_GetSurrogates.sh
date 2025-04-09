#!/bash/sh
set -e

echo "++ INFO: Loading python environment ...."
source /data/SFIMJGC_HCP7T/Apps/miniconda38/etc/profile.d/conda.sh && conda activate bcbl_visit

INPUT_PATH=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/${SBJ}/${SBJ}_ants_transformed-MNI_REST-ICs.2p5mm_iso.comp_${IC}.txt`
OUTPUT_PATH=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/${SBJ}/burton2020/`

echo "INPUT_PATH = ${INPUT_PATH}"
echo "OUTPUT_PATH = ${OUTPUT_PATH}"

if [ ! -d ${OUTPUT_PATH} ]; then
   mkdir -p ${OUTPUT_PATH}
fi

python /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/code/python/run_get_surrogates.py \
       -input ${INPUT_PATH} \
       -output ${OUTPUT_PATH} \
       -sbj ${SBJ} \
       -ic ${IC} \
       -ns 500 \
       -knn 1500 \
       -pv 70 \
       -n_perms ${N_PERMS} \
       -n_jobs ${N_JOBS} 

echo "++ INFO: Program finished succesfully --> outputs in ${OUTPUT_PATH}"
