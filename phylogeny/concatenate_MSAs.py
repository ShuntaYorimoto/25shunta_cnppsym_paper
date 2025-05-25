#!/usr/bin/env python3

import os
import argparse
from Bio import SeqIO
from collections import defaultdict

def get_species_names(species_dir):
    """
    Extract species names from the filenames in the species directory.
    """
    species_names = []
    for filename in sorted(os.listdir(species_dir)):
        if filename.endswith(".faa"):
            species_name = filename.replace(".faa", "")
            species_names.append(species_name)
    return species_names

def concatenate_alignments(input_dir, species_names, output_path):
    """
    Concatenate multiple MSA files by species.
    """
    # List to store sequences from each MSA file
    all_sequences = []
    msa_count = 0

    # Process all MSA files in the input directory
    for filename in sorted(os.listdir(input_dir)):
        if filename.endswith(".fa"):
            filepath = os.path.join(input_dir, filename)
            sequences = list(SeqIO.parse(filepath, "fasta"))
            all_sequences.append(sequences)
            msa_count += 1

    # Dictionary to store concatenated sequences for each species
    concatenated_sequences = defaultdict(str)
    
    # Concatenate sequences for each species across all MSA files
    for i in range(len(species_names)):
        for seq_list in all_sequences:
            concatenated_sequences[species_names[i]] += str(seq_list[i].seq)
    
    # Write concatenated sequences to output file
    with open(output_path, "w") as output_handle:
        for species, concatenated_seq in concatenated_sequences.items():
            output_handle.write(f">{species}\n")
            output_handle.write(f"{concatenated_seq}\n")
            
    return msa_count, len(concatenated_sequences)

def main():
    parser = argparse.ArgumentParser(description='Concatenate multiple MSA files by species')
    parser.add_argument('-s', '--species_dir', required=True,
                        help='Path to directory containing species FASTA files (.faa)')
    parser.add_argument('-i', '--indir', required=True,
                        help='Path to directory containing MSA files (.fa)')
    parser.add_argument('-o', '--outdir', required=True,
                        help='Path to output directory')
    
    args = parser.parse_args()
    
    # Ensure output directory exists
    if not os.path.exists(args.outdir):
        os.makedirs(args.outdir)
        print(f"Created directory: {args.outdir}")
    
    # Set fixed output filename
    output_filename = "concatenated_MSAs.fa"
    output_path = os.path.join(args.outdir, output_filename)
    
    # Get species names list
    species_names = get_species_names(args.species_dir)
    print(f"Found {len(species_names)} species")
    
    # Perform concatenation
    msa_count, species_count = concatenate_alignments(args.indir, species_names, output_path)
    
    # Report results
    print(f"Processed {msa_count} MSA files")
    print(f"Concatenated sequences for {species_count} species")
    print(f"Output written to: {output_path}")

if __name__ == "__main__":
    main()
