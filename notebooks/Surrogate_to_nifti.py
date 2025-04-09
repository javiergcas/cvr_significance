# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:light
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.16.1
#   kernelspec:
#     display_name: BCBL Visit (March 2025)
#     language: python
#     name: bcbl_visit
# ---

# # Description
#
# This notebook shows how to convert a surrogate map in txt file into a nifti file we can open in AFNI

import numpy as np

surr_path = '/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/sub-008/burton2020/sub-008_ants_transformed-MNI_REST-ICs.2p5mm_iso.comp_0.surrogate_maps.npy'

surr_data = np.load(surr_path)
print(surr_data.shape)

np.savetxt('./a.txt',surr_data[:,0])

# Then, you can regenerate the map for this particular surrogate as follows:
#
# ```bash
# # cd /data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/sub-008
# paste ./sub-008_GMmask.2p5mm_iso.xyz.txt ../../../code/notebooks/a.txt > ./input.txt
# 3dUndump -overwrite -orient RAI -prefix test.nii -xyz -master sub-008_GMmask.2p5mm_iso.nii.gz input.txt
# ```


