#!/usr/bin/env python3

import argparse
import re
import os

def process_gff(gff_file, prefix, output_file):
    """
    Process a single GFF file to create MCScanX bed format with custom chromosome prefix.
    
    Args:
        gff_file: Path to input GFF file
        prefix: Prefix to add to chromosome names
        output_file: Path to output BED file
    """
    
    count = 0
    
    with open(gff_file, 'r') as f, open(output_file, 'w') as out:
        for line in f:
            # Skip comment lines or FASTA section
            if line.startswith("#") or line.startswith(">"):
                continue
                
            parts = line.strip().split("\t")
            
            # Check if line has enough fields and is a CDS entry
            if len(parts) >= 9 and parts[2] == "CDS":
                chrom = f"{prefix}_{parts[0]}"  # Add prefix to chromosome name
                
                # Extract gene ID from attributes field
                id_match = re.search(r'ID=([^;]+)', parts[8])
                if id_match:
                    gene_id_base = id_match.group(1)
                    gene_id = f"{prefix}_{gene_id_base}"
                    # Get start and end positions
                    start = parts[3]
                    end = parts[4]
                    
                    # Write in MCScanX format: chr gene_id start end
                    out.write(f"{chrom}\t{gene_id}\t{start}\t{end}\n")
                    count += 1
    
    print(f"Processed {count} CDS entries.")
    print(f"Output written to {output_file}")

def main():
    parser = argparse.ArgumentParser(description='Process a GFF file for MCScanX input with custom chromosome prefix')
    parser.add_argument('-g', '--gff', required=True, help='Input GFF file')
    parser.add_argument('-p', '--prefix', required=True, help='Prefix for genome')
    parser.add_argument('-o', '--output', required=True, help='Output BED file')
    
    args = parser.parse_args()
    
    # Process GFF file
    process_gff(args.gff, args.prefix, args.output)

if __name__ == "__main__":
    main()
