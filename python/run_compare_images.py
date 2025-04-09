import argparse
import os.path as osp
import numpy as np
import pandas as pd
import os
from tqdm import tqdm
from scipy.stats import pearsonr, spearmanr
def run(args):
    print('++ INFO: Entering run function....')
    print('         * path to rs data           = %s' % args.rest_input)
    print('         * path to bh data           = %s' % args.bh_input)
    print('         * path to rs surrogate data = %s' % args.rest_surrogates)
    print('         * path to output file       = %s' % args.output_path)
    print('         * rest IC ID                = %d' % args.rest_ic)
    print('         * metric                    = %s' % args.metric) 
    for input_path in [args.rest_input, args.bh_input, args.rest_surrogates]:
        if not osp.exists(input_path):
            print('++ ERROR: Input file [%s] is missing.' % input_path)
            return 1

    # Load data into memory
    print('++ INFO: loading data into memory....')
    rest_ics  = np.loadtxt(args.rest_input)
    print('         rest_ics shape is            %s' % str(rest_ics.shape))
    bh_ics    = np.loadtxt(args.bh_input)
    print('         bh_ics shape is              %s' % str(bh_ics.shape))
    rest_surr = np.load(args.rest_surrogates)
    print('         rest_surrogates_ics shape is %s' % str(rest_surr.shape))

    # Compute the null distribution of R values
    print('++ INFO: Compute null distribution of R values based on surrogate data')
    df_surr = pd.DataFrame(columns=['R','p'])
    for i in tqdm(range(rest_surr.shape[1])):
        if args.metric == 'pearsonr':
            r,p = pearsonr(rest_ics[:,0],rest_surr[:,i])
        if args.metric == 'spearmanr':
            r,p = spearmanr(rest_ics[:,0],rest_surr[:,i])
        df_surr.loc[i,'R'] = r
        df_surr.loc[i,'p'] = p
    df_surr = df_surr.infer_objects()
    df_surr.index.name = 'permutation_id'

    # Compute R and parametric p-value for rest component IC vs. all bh components
    n_bh_components = bh_ics.shape[1]
    print('++ INFO: Computing Correlation and parametric p-val between rest component %d and %d breath hold components' % (args.rest_ic, n_bh_components)) 
    df_rsVSbh = pd.DataFrame(index=range(n_bh_components), columns=['R','p_val (parametric)'])
    for bh in tqdm(range(n_bh_components)):
        r,p = pearsonr(rest_ics[:,args.rest_ic],bh_ics[:,bh])
        df_rsVSbh.loc[bh,'R'] = r
        df_rsVSbh.loc[bh,'p_val (parametric)'] = p
    df_rsVSbh = df_rsVSbh.infer_objects()
    df_rsVSbh.index.name = 'BH_component_id'
    
    # Compute non-parametric p-value
    print('++ INFO: Computing non-parametric p-values')
    for bh in tqdm(range(n_bh_components)):
        this_R = df_rsVSbh.loc[bh,'R']
        if this_R > 0:
            p = (df_surr['R'] > this_R).sum() / 10000
        else:
            p = (df_surr['R'] < this_R).sum() / 10000
        df_rsVSbh.loc[bh,'p_val (non parametric)'] = p

    # Save results to disk
    print('++ INFO: Saving statistics to disk [%s].' % args.output_path)
    df_rsVSbh.to_csv(args.output_path)
    print('++ INFO: Program finished successfully')

def main():
    # Parse input arguments
    parser=argparse.ArgumentParser(description="Saves Neurosynth metamaps for a given topic to disk.")
    parser.add_argument("-rest_input",       help="Path to rest component maps in txt format"   ,dest="rest_input",      type=str, required=True)
    parser.add_argument("-bh_input",         help="Path to bh component maps in txt format"     ,dest="bh_input",        type=str, required=True)
    parser.add_argument("-rest_surrogates",  help="Path to rest surrogate maps in txt format"   ,dest="rest_surrogates", type=str, required=True)
    parser.add_argument("-output_path",      help='Output Path'                                 ,dest='output_path',     type=str, required=True)
    parser.add_argument("-rest_ic",       help="Compnent ID"                                    ,dest="rest_ic",         type=int, required=True)
    parser.add_argument("-metric",       help="Comparison metric"                               ,dest="metric",          type=str, required=False, choices=['pearsonr','spearmanr'], default='pearsonr')

    parser.set_defaults(func=run)
    args=parser.parse_args()
    args.func(args)
    
if __name__ == "__main__":
    main()
