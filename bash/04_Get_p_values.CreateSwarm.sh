# Author: Javier Gonzalez-Castillo
# Date: 04/07/2025
#
# Description:
# Convert all data to 2.5 iso
# Extract TS to text file
set -e

N_PERMS=10000
N_JOBS=32

PRJ_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/'
DATA_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/orig_data/'
BASH_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/code/bash/'
PYTHON_DIR='/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/code/python/'
USERNAME=`whoami`
SWARM_DIR=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/swarm.${USERNAME}`
SWARM_PATH=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/swarm.${USERNAME}/04_Get_p_values.SWARM.sh`
LOGS_DIR=`echo /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/logs.${USERNAME}/04_Get_p_values.logs`
subjects=(sub-001 sub-002  sub-003	sub-004  sub-007  sub-008)
sessions=(ses-01  ses-02  ses-03  ses-04  ses-05  ses-06  ses-07  ses-08  ses-09  ses-10)
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
echo "#swarm -f ${SWARM_PATH} -g 16 -t 16 -b 20 --time 00:12:00 --partition quick,norm --logdir ${LOGS_DIR}" > ${SWARM_PATH}

# Create log directory if needed (for swarm files)
# ------------------------------------------------
if [ ! -d ${LOGS_DIR} ]; then 
   mkdir -p ${LOGS_DIR}
fi

# Create directory for all fMRI data processing files per subject if needed
# -------------------------------------------------------------------------
for SBJ in ${subjects[@]}
do
  for SES in ${sessions[@]}
  do
     for REST_IC in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19
     do
         echo "export SBJ=${SBJ} SES=${SES} REST_IC=${REST_IC}; sh ${BASH_DIR}/04_Get_p_values.sh" >> ${SWARM_PATH}
     done
  done
done

