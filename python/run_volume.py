import argparse
import os.path as osp
import numpy as np
import os
from brainsmash.workbench.geo import volume

def run(args):
    print('++ INFO: Entering run function....')
    if not osp.exists(args.input_path):
        print("++ ERROR: Input not found [%s]" % args.input_path)
        return -1
    if not osp.isdir(args.output_path):
        print("++ ERROR: Output folder not found [%s]" % args.output_path)
        return -1
    # Compute distance matrix
    print('++ INFO: Calculating and saving voxel-wise distance matrix....')
    filenames = volume(args.input_path, args.output_path)

    # Save output object too (OPTIONAL)
    print('++ INFO: Saving filenames object to disk...')
    filenames_path = osp.join(args.output_path,f'{args.sbj}_filenames.npy')
    np.save(filenames_path,filenames)

def main():
    # Parse input arguments
    parser=argparse.ArgumentParser(description="Saves Neurosynth metamaps for a given topic to disk.")
    parser.add_argument("-input",       help="Input map to be randomized" ,dest="input_path",  type=str, required=True)
    parser.add_argument("-output", help='Output Path',   dest='output_path', type=str, required=True)
    parser.add_argument("-sbj",       help="Subject ID"     ,dest="sbj",     type=str, required=True)

    parser.set_defaults(func=run)
    args=parser.parse_args()
    args.func(args)
    
if __name__ == "__main__":
    main()
