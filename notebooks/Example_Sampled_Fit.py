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

from brainsmash.mapgen.eval import sampled_fit
import os.path as osp

x = '/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/sub-001/sub-001_ants_transformed-MNI_REST-ICs.2p5mm_iso.comp_0.txt'
filenames = {}
filenames['D']     = osp.join('/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/sub-001/burton2020/distmat.npy')
filenames['index'] = osp.join('/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH/data/prcs_data/sub-001/burton2020/index.npy')

kwargs = {'ns': 500,
          'knn': 1500,
          'pv': 70
          }

sampled_fit(x, filenames['D'], filenames['index'], nsurr=10000, **kwargs)


