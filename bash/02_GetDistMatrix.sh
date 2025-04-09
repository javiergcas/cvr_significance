#!/bash/sh
set -e

echo "++ INFO: Loading python environment ...."
source /data/SFIMJGC_HCP7T/Apps/miniconda38/etc/profile.d/conda.sh && conda activate bcbl_visit

INPUT_PATH=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/${SBJ}/${SBJ}_GMmask.2p5mm_iso.xyz.txt`
OUTPUT_PATH=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/${SBJ}/burton2020/`

echo "INPUT_PATH = ${INPUT_PATH}"
echo "OUTPUT_PATH = ${OUTPUT_PATH}"

if [ ! -d ${OUTPUT_PATH} ]; then
   mkdir -p ${OUTPUT_PATH}
fi

python /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/code/python/run_volume.py \
       -input ${INPUT_PATH} \
       -output ${OUTPUT_PATH} \
       -sbj ${SBJ}

echo "++ INFO: Program finished succesfully --> output in ${OUTPUT_PATH}"
