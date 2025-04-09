# Author: Javier Gonzalez-Castillo
# Date: 04/07/2025
#
# Description:
# Convert all data to 2.5mm iso
# Create FB - WM mask at 2.5mm iso
# Extract ROI Coordinates
# Convert bh components to text file (best way to input to the burton 2020 code)
# Convert rest components to text file (best way to input to the burton 2020 code)
set -e
ml afni

PRJ_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/'
ORIG_DATA_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/orig_data/'
PRCS_DATA_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/'
RESOURCES_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/resources/'

BASH_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/code/bash/'
PYTHON_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/code/python/'

if [ ! -d ${PRCS_DATA_DIR}/${SBJ} ]; then
   mkdir -p ${PRCS_DATA_DIR}/${SBJ}
fi
# Create Resampled version of rs networks to 2.5mm iso as NIFTI files
# ===================================================================
# NOTE: The EPI reference volume must be ctrated prior to running this code
#       You can create it this way: 3dresample -dxyz 2.5 2.5 2.5 -input '../orig_data/sub-001/rest/ants_transformed-MNI_melodic_IC.nii.gz[0]' -prefix EPIREF.2p5mm_iso.nii.gz
echo "++ INFO: Resampling RS components to 2.5iso..."
EPIREF_PATH=`echo ${RESOURCES_DIR}/EPIREF.2p5mm_iso.nii.gz`
3dresample -overwrite -master ${EPIREF_PATH} -input ${ORIG_DATA_DIR}/${SBJ}/rest/ants_transformed-MNI_melodic_IC.nii.gz -prefix ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_ants_transformed-MNI_REST-ICs.2p5mm_iso.nii.gz

# Create Resampled version of bh networks to 2.5mm iso as NIFTI files
# ===================================================================
echo "++ INFO: Resamping BH components to 2.5iso...."
for SES in ses-01  ses-02  ses-03  ses-04  ses-05  ses-06  ses-07  ses-08  ses-09  ses-10
do
    3dresample -overwrite -master ${EPIREF_PATH} -input ${ORIG_DATA_DIR}/${SBJ}/${SES}/ants_transformed-to_MNI152NLin6Asym_desc-ICA_components_sm2_preserved.nii.gz -prefix ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_${SES}_ants_transformed-MNI_CVR-ICs.2p5mm_iso.nii.gz
done

# Create FB - WM mask in 2.5iso grid
# ==================================
echo "++ INFO: Generating subject-specific GM mask at 2.5mm resolution...."

# Get common FOV across all BH session
3dMean -overwrite -prefix ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_FBmask.pmap.nii.gz ${ORIG_DATA_DIR}/${SBJ}/ses-??/ants_transformed-MNI_sub-???_ses-??_task-breathhold_desc-brain_mask.nii.gz
3dcalc -overwrite -a ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_FBmask.pmap.nii.gz -expr 'equals(a,1)' -prefix ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_FBmask.nii.gz

# Resample to 2.5 iso
3dresample -overwrite -master ${EPIREF_PATH} -input ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_FBmask.nii.gz -prefix ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_FBmask.2p5mm_iso.nii.gz

# Take out the WM voxels
3dcalc -overwrite -a ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_FBmask.2p5mm_iso.nii.gz -b ${RESOURCES_DIR}/MNI152_2009_template_SSW.2p5mm_iso.nii.gz[4] -expr 'a*b' -prefix ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_GMmask.2p5mm_iso.nii.gz

# Extract ROI Coordinates for the remaining voxels. This is one input needed by Burton 2020
# =========================================================================================
echo "++ INFO: Extracting coordinates of all voxels in GM mask..."
3dmaskdump -noijk -quiet -xyz -mask ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_GMmask.2p5mm_iso.nii.gz ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_GMmask.2p5mm_iso.nii.gz > ${PRCS_DATA_DIR}/${SBJ}/rm.${SBJ}_GMmask.2p5mm_iso.xyz.txt
cat ${PRCS_DATA_DIR}/${SBJ}/rm.${SBJ}_GMmask.2p5mm_iso.xyz.txt | awk '{print $1" "$2" "$3}' > ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_GMmask.2p5mm_iso.xyz.txt
rm ${PRCS_DATA_DIR}/${SBJ}/rm.${SBJ}_GMmask.2p5mm_iso.xyz.txt


# Extract voxel values for resting-state networks
# ===============================================
echo "++ INFO: Converting RS maps to text files...."
3dmaskdump -noijk -quiet -mask ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_GMmask.2p5mm_iso.nii.gz ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_ants_transformed-MNI_REST-ICs.2p5mm_iso.nii.gz > ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_ants_transformed-MNI_REST-ICs.2p5mm_iso.txt
for ic in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20
do
   ic_plus=`echo "${ic}+1" | bc`
   cat ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_ants_transformed-MNI_REST-ICs.2p5mm_iso.txt |  awk -v i="$ic_plus" '{print $i}' > ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_ants_transformed-MNI_REST-ICs.2p5mm_iso.comp_${ic}.txt
done


# Extract voxel values for breath-hold networks
echo "++ INFO: Converting BH maps to text files....."
for SES in ses-01  ses-02  ses-03  ses-04  ses-05  ses-06  ses-07  ses-08  ses-09  ses-10
do
   3dmaskdump -noijk -quiet -mask ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_GMmask.2p5mm_iso.nii.gz ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_${SES}_ants_transformed-MNI_CVR-ICs.2p5mm_iso.nii.gz > ${PRCS_DATA_DIR}/${SBJ}/${SBJ}_${SES}_ants_transformed-MNI_CVR-ICs.2p5mm_iso.txt
done

echo "++ =================================="
echo "++ INFO: Script finished successfully"
echo "++ =================================="
