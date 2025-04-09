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

import pandas as pd
import numpy as np
import xarray as xr
import hvplot.pandas
import os.path as osp
from tqdm import tqdm
import seaborn as sns
import holoviews as hv

PRJ_DIR = '/data/SFIMJGC_HCP7T/2025_BCBL_VisitNIH'
sbj_list = ['sub-001',  'sub-002',  'sub-003',  'sub-004',  'sub-007',  'sub-008']
ses_list = ['ses-01',  'ses-02',  'ses-03',  'ses-04',  'ses-05',  'ses-06',  'ses-07',  'ses-08',  'ses-09',  'ses-10']
num_rest_ics = 20

df = pd.DataFrame(columns=['sbj','ses','rs_ic','bh_ic','R','p_val (param)','p_val (burton2020)'])
df_list = []
for sbj in sbj_list:
    for ses in tqdm(ses_list):
        for rs_ic in range(num_rest_ics):
            input_path = osp.join(PRJ_DIR,'data','prcs_data',sbj,'burton2020',f'{sbj}_REST-IC-{rs_ic}_vs_BH_{ses}.txt')
            aux = pd.read_csv(input_path, index_col=[0])
            num_bhs = aux.shape[0]
            for bh_ic in range(num_bhs):
                df_list.append({'sbj':sbj, 'ses':ses, 'rs_ic':rs_ic, 'bh_ic':bh_ic, 'R':aux.loc[bh_ic,'R'],'p_val (param)':aux.loc[bh_ic,'p_val (parametric)'], 'p_val (burton2020)':aux.loc[bh_ic,'p_val (non parametric)']})

df = pd.DataFrame(df_list)

df.info()

sbj       = 'sub-007'
num_comps = df.set_index(['sbj']).loc[sbj].shape[0]
print(sbj,num_comps)

df_significat = df[df['p_val (burton2020)']< 0.05 / num_comps ]

df.set_index(['sbj','ses']).loc[sbj].apply(np.abs).hvplot.violin(by='rs_ic',y='R', width=1500) * \
df.set_index(['sbj','ses']).loc[sbj].apply(np.abs).hvplot.scatter(x='rs_ic',y='R', size=5, hover_cols=['sbj','ses','p_val (burton2020)','bh_ic']) * \
df_significat.set_index(['sbj','ses']).loc[sbj].apply(np.abs).hvplot.scatter(x='rs_ic',y='R', c='r',hover_cols=['sbj','ses','p_val (burton2020)','bh_ic'], size=5)
