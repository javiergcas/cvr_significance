import argparse
import os.path as osp
import numpy as np
import os
from brainsmash.mapgen.sampled import Sampled

def run(args):
    print('++ INFO: Entering run function....')
    print('         * input rs map   = %s' % args.input_path)
    print('         * output folder  = %s' % args.output_path)
    print('         * sbj ID         = %s' % args.sbj)
    print('         * rest IC ID     = %s' % args.ic)
    print('         * n_jobs         = %d' % args.n_jobs)
    print('         * n_perms        = %d' % args.n_perms)
    print('         * pv             = %d' % args.pv) 
    print('         * ns             = %d' % args.ns) 
    print('         * knn            = %d' % args.knn) 
    if not osp.exists(args.input_path):
        print("++ ERROR: Input not found [%s]" % args.input_path)
        return -1
    if not osp.isdir(args.output_path):
        print("++ ERROR: Output folder not found [%s]" % args.output_path)
        return -1
    # Loading filenames object
    filenames_path = osp.join(args.output_path,f'{args.sbj}_filenames.npy')
    print('++ INFO: Loading filenames object from disk [%s]' % filenames_path)
    filenames = {}
    filenames['D']     = osp.join(args.output_path,'distmat.npy') 
    filenames['index'] = osp.join(args.output_path,'index.npy') 
    # Get surrogate maps
    print('++ INFO: Generating %d surrogate maps. This will take a while....' % args.n_perms)
    gen = Sampled(x=args.input_path, D=filenames['D'], index=filenames['index'], ns=args.ns, knn=args.knn, pv=args.pv, n_jobs=args.n_jobs, verbose=True)
    surr_maps = gen(n=args.n_perms)

    # Write surrogate maps to disk
    surr_maps_path = osp.join(args.output_path,f'{args.sbj}_ants_transformed-MNI_REST-ICs.2p5mm_iso.comp_{args.ic}.surrogate_maps.npy')
    print('++ INFO: Writting surrogate maps to disk [%s]' % surr_maps_path)
    np.save(surr_maps_path, surr_maps.T) 

    print('++ INFO: Program finished successfully')

def main():
    # Parse input arguments
    parser=argparse.ArgumentParser(description="Saves Neurosynth metamaps for a given topic to disk.")
    parser.add_argument("-input",       help="Input map to be randomized" ,dest="input_path",  type=str, required=True)
    parser.add_argument("-output", help='Output Path',   dest='output_path', type=str, required=True)
    parser.add_argument("-sbj",       help="Subject ID"     ,dest="sbj",     type=str, required=True)
    parser.add_argument("-ic",       help="Compnent ID"     ,dest="ic",     type=str, required=True)
    parser.add_argument("-n_perms",   help="Number of Permutations" ,dest="n_perms",     type=int, required=True)
    parser.add_argument("-n_jobs",   help="Number of Jobs" ,dest="n_jobs",     type=int, required=True)
    parser.add_argument("-ns",   help="Take a subsample of ns rows from D when fitting variograms" ,dest="ns",     type=int, required=True)
    parser.add_argument("-knn",   help="Number of nearest regions to keep in the neighborhood of each region" ,dest="knn",     type=int, required=True)
    parser.add_argument("-pv",   help="Percentile of the pairwise distance distribution (in D) at which to truncate during variogram fitting" ,dest="pv",     type=int, required=True)

    parser.set_defaults(func=run)
    args=parser.parse_args()
    args.func(args)
    
if __name__ == "__main__":
    main()
