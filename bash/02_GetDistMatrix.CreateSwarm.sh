# Author: Javier Gonzalez-Castillo
# Date: 04/07/2025
#
# Description:
# Convert all data to 2.5 iso
# Extract TS to text file
set -e

PRJ_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/'
DATA_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/orig_data/'
BASH_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/code/bash/'
PYTHON_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/code/python/'
USERNAME=`whoami`
SWARM_DIR=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/swarm.${USERNAME}`
SWARM_PATH=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/swarm.${USERNAME}/02_GetDistMatrix.SWARM.sh`
LOGS_DIR=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/logs.${USERNAME}/02_GetDistMatrix.logs`
subjects=(sub-001 sub-002  sub-003	sub-004  sub-007  sub-008)
echo "++ Subjects: ${subjects[@]}"
echo "++ Orig Data Folder  : ${DATA_DIR}"
echo "++ Bash Folder       : ${BASH_DIR}"
echo "++ Python Folder     : ${PYTHON_DIR}"
echo "++ Swarm Folder      : ${SWARM_PATH}"
echo "++ Logs Folder       : ${LOGS_DIR}"

# Create log directory if needed
# ------------------------------
if [ ! -d ${SWARM_DIR} ]; then
   mkdir -p ${SWARM_DIR}
fi

# Initialize Swarm File
# ---------------------
echo "#swarm -f ${SWARM_PATH} -g 256 -t 4 --time 01:00:00 --partition quick,norm --logdir ${LOGS_DIR} --sbatch \"--export AFNI_COMPRESSOR=GZIP\"" > ${SWARM_PATH}

# Create log directory if needed (for swarm files)
# ------------------------------------------------
if [ ! -d ${LOGS_DIR} ]; then 
   mkdir -p ${LOGS_DIR}
fi

# Create directory for all fMRI data processing files per subject if needed
# -------------------------------------------------------------------------
for SBJ in ${subjects[@]}
do
  echo "export SBJ=${SBJ}; sh ${BASH_DIR}/02_GetDistMatrix.sh" >> ${SWARM_PATH}
done

