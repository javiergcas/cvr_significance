import argparse
import os.path as osp
import numpy as np
import os
from neuromaps import nulls
from neuromaps.transforms import mni152_to_mni152

def run(args):
    print('++ INFO: Entering run function....')
    if not osp.exists(args.input_path):
        print("++ ERROR: Input not found [%s]" % input_path)
        return -1
    # Resample to mni
    print("++ INFO: Resampling input data....")
    resampled_data = mni152_to_mni152(args.input_path,args.density,'nearest')
    # Generate null models
    print('++ INFO: Starting to generate moran null models')
    null_maps = nulls.burton2020(resampled_data, atlas='MNI152', density=args.density, n_perm = args.n_perm, n_proc = args.n_proc)
    #null_maps = nulls.moran(resampled_data, atlas='MNI152', density=args.density, n_perm = args.n_perm, n_proc = args.n_proc)
    # Saving null models to disk
    output_dir, output_file = os.path.split(args.output_path)
    if not osp.exists(output_dir):
        print("++ INFO: Creating output folder recursively")
        os.makedirs(output_dir)
    print('++ INFO: Writting null models to disk [%s]' % args.output_path)
    np.save(args.output_path, null_maps)
def main():
    # Parse input arguments
    parser=argparse.ArgumentParser(description="Saves Neurosynth metamaps for a given topic to disk.")
    parser.add_argument("-input",       help="Input map to be randomized" ,dest="input_path",  type=str, required=True)
    parser.add_argument("-output", help='Output Path',   dest='output_path', type=str, required=True)
    parser.add_argument("-space",       help="Final Space"     ,dest="space",     type=str, required=True, default='mni152')
    parser.add_argument("-density",       help="Final Resolution"     ,dest="density",     type=str, required=True, default='2mm', choices=['1mm','2mm','3mm'])
    parser.add_argument("-n_perm", help='Number of permutations', dest='n_perm', type=int, required=False, default=1000)
    parser.add_argument("-n_proc", help='Number of processors',   dest='n_proc', type=int, required=False, default=-1)

    parser.set_defaults(func=run)
    args=parser.parse_args()
    args.func(args)
    
if __name__ == "__main__":
    main()
