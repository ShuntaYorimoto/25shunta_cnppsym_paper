#!/usr/bin/env python3

import pandas as pd
from pygenomeviz import GenomeViz
from pygenomeviz.parser import Genbank
import matplotlib.pyplot as plt

# Set font
matplotlib.rcParams['font.family'] = 'sans-serif'
matplotlib.rcParams['font.sans-serif'] = ['Arial']

# Load RBH results
print("Loading RBH data...")
rbh_apis_cjap = pd.read_csv('rbh_apis_cjap.tsv', sep='\t')
rbh_cjap_cnek = pd.read_csv('rbh_cjap_cnek.tsv', sep='\t')
rbh_cnek_ppan = pd.read_csv('rbh_cnek_ppan.tsv', sep='\t')

# Load GFF files
print("Loading GFF files...")
gbk_apis = Genbank('genbanks/buchnera_apis.gbk')
gbk_cjap = Genbank('genbanks/buchnera_cjap.gbk')
gbk_cnek = Genbank('genbanks/buchnera_cnek.gbk')
gbk_ppan = Genbank('genbanks/buchnera_ppan.gbk')

# Get chromosome names (exclude plasmids by selecting largest sequence)
def get_chromosome(gbk_parser):
    """ Extract chromosome contig (largest sequence) """
    seqid2size = gbk_parser.get_seqid2size()
    chromosome = max(seqid2size, key=seqid2size.get)
    max_length = seqid2size[chromosome]
    return chromosome, max_length

chr_apis, len_apis = get_chromosome(gbk_apis)
chr_cjap, len_cjap = get_chromosome(gbk_cjap)
chr_cnek, len_cnek = get_chromosome(gbk_cnek)
chr_ppan, len_ppan = get_chromosome(gbk_ppan)

print(f"\nA. pisum chromosome: {chr_apis} ({len_apis:,} bp)")
print(f"C. japonica chromosome: {chr_cjap} ({len_cjap:,} bp)")
print(f"C. nekoashi chromosome: {chr_cnek} ({len_cnek:,} bp)")
print(f"P. panicola chromosome: {chr_ppan} ({len_ppan:,} bp)")

# Filter RBH results for chromosomes only
rbh_apis_cjap_chr = rbh_apis_cjap[
    (rbh_apis_cjap['contig_a'] == chr_apis) & 
    (rbh_apis_cjap['contig_b'] == chr_cjap)
].copy()

rbh_cjap_cnek_chr = rbh_cjap_cnek[
    (rbh_cjap_cnek['contig_a'] == chr_cjap) & 
    (rbh_cjap_cnek['contig_b'] == chr_cnek)
].copy()

rbh_cnek_ppan_chr = rbh_cnek_ppan[
    (rbh_cnek_ppan['contig_a'] == chr_cnek) & 
    (rbh_cnek_ppan['contig_b'] == chr_ppan)
].copy()

print(f"\nRBH links (Apis-Cjap): {len(rbh_apis_cjap_chr)}")
print(f"RBH links (Cjap-Cnek): {len(rbh_cjap_cnek_chr)}")
print(f"RBH links (Cnek-Ppan): {len(rbh_cnek_ppan_chr)}")

# Initialize GenomeViz
gv = GenomeViz(fig_track_height=0.8, track_align_type="left", feature_track_ratio=0.1)
gv.set_scale_xticks(ymargin=3)

# Add tracks (top to bottom: A. pisum -> C. japonica -> C. nekoashi -> P. panicola)
track_apis = gv.add_feature_track("A. pisum", len_apis)
track_cjap = gv.add_feature_track("C. japonica", len_cjap)
track_cnek = gv.add_feature_track("C. nekoashi", len_cnek)
track_ppan = gv.add_feature_track("P. panicola", len_ppan)

# Add features
def add_features_to_track(track, gbk_parser, chromosome_name):
    """Add CDS, rRNA, tRNA features with color coding"""
    features = gbk_parser.get_seqid2features(feature_type=None)[chromosome_name]
    
    for feature in features:
        if feature.type == "CDS":
            track.add_features(feature, plotstyle="arrow", fc="blue")
        elif feature.type == "rRNA":
            track.add_features(feature, plotstyle="arrow", fc="lime")
        elif feature.type == "tRNA":
            track.add_features(feature, plotstyle="arrow", fc="magenta")

add_features_to_track(track_apis, gbk_apis, chr_apis)
add_features_to_track(track_cjap, gbk_cjap, chr_cjap)
add_features_to_track(track_cnek, gbk_cnek, chr_cnek)
add_features_to_track(track_ppan, gbk_ppan, chr_ppan)

# Add chromosome length
track_apis.add_sublabel(ymargin=0.5)
track_cjap.add_sublabel(ymargin=0.5)
track_cnek.add_sublabel(ymargin=0.5)
track_ppan.add_sublabel(ymargin=0.5)

# Add links between A. pisum and C. japonica
for _, row in rbh_apis_cjap_chr.iterrows():
    gv.add_link(
        (track_apis.name, row['genome_a_start'], row['genome_a_end']),
        (track_cjap.name, row['genome_b_start'], row['genome_b_end']),
        color="grey", inverted_color='red',
        v=row["identity"], vmin=30,
        alpha=0.5, curve=True
    )

# Add links between C. japonica and C. nekoashi
for _, row in rbh_cjap_cnek_chr.iterrows():
    gv.add_link(
        (track_cjap.name, row['genome_a_start'], row['genome_a_end']),
        (track_cnek.name, row['genome_b_start'], row['genome_b_end']),
        color="grey", inverted_color='red',
        v=row["identity"], vmin=30,
        alpha=0.5, curve=True
    )

# Add links between C. nekoashi and P. panicola
for _, row in rbh_cnek_ppan_chr.iterrows():    
    gv.add_link(
        (track_cnek.name, row['genome_a_start'], row['genome_a_end']),
        (track_ppan.name, row['genome_b_start'], row['genome_b_end']),
        color="grey", inverted_color='red',
        v=row["identity"], vmin=30,
        alpha=0.5, curve=True
    )

# Plot figure
gv.set_colorbar(['grey', 'red'], vmin=30, bar_label="Identity (%)")
fig = gv.plotfig()

# Save outputs
output_png = 'buchnera_synteny_plot.png'
output_svg = 'buchnera_synteny_plot.svg'

fig.savefig(output_png, dpi=300, bbox_inches='tight')
fig.savefig(output_svg, bbox_inches='tight')

print(f"\nSaved: {output_png}")
print(f"Saved: {output_svg}")

plt.close()
