#!/usr/bin/env python3
"""
Visualize Buchnera aphidicola genome of Ceratovacuna nekoashi
"""

from pycirclize import Circos
from pycirclize.parser import Genbank
from matplotlib.patches import Patch
import numpy as np
import matplotlib.pyplot as plt

# Set font
plt.rcParams['font.family'] = 'Arial'

# Load GenBank file
species = "BucPp"
gbk = Genbank(f"{species}.gbk")
seqid2size = gbk.get_seqid2size()
seqid2seq = gbk.get_seqid2seq()
seqid2features = gbk.get_seqid2features(feature_type=None)

# Color scheme
colors = {
    'forward_cds': 'tomato',
    'reverse_cds': 'skyblue',
    'rrna': 'lime',
    'trna': 'magenta',
    'gc_content_pos': 'black',
    'gc_content_neg': 'grey',
    'gc_skew_pos': 'olive',
    'gc_skew_neg': 'purple'
}

def get_plot_parameters(seqid):
    """Get plot parameters based on sequence type"""
    if seqid == 'chromosome':
        return {
            'major_interval': 100000,
            'minor_interval': 20000,
            'window_size': 500,
            'step_size': 250,
            'figsize': 4,
            'label_format': 'Mb'
        }
    else:  # plasmids (pLeu, pTrp)
        return {
            'major_interval': 2000,
            'minor_interval': 500,
            'window_size': 50,
            'step_size': 25,
            'figsize': 2,
            'label_format': 'Kb'
        }

# Plot each sequence separately
plot_order = ['chromosome', 'pLeu', 'pTrp']

for seqid in plot_order:
    params = get_plot_parameters(seqid)
    
    # Create Circos instance
    circos = Circos(sectors={seqid: seqid2size[seqid]}, space=0)
    sector = circos.sectors[0]
    
    # Track 1: Outer axis with ticks
    outer_track = sector.add_track((98, 100))
    outer_track.axis(fc="lightgrey", ec="black", lw=0.5)
    outer_track.xticks_by_interval(
        params['major_interval'],
        label_formatter=lambda v: f"{v/1000:.1f} Kb" if params['label_format'] == 'Kb' else f"{v/1000000:.2f} Mb",
        label_size=6,
        label_orientation="vertical"
    )
    outer_track.xticks_by_interval(params['minor_interval'], tick_length=1, show_label=False)
    
    # Track 2: Forward CDS
    f_cds_track = sector.add_track((90, 97), r_pad_ratio=0.1)
    f_cds_track.axis(fc="none", ec="none")
    
    # Track 3: Reverse CDS
    r_cds_track = sector.add_track((83, 90), r_pad_ratio=0.1)
    r_cds_track.axis(fc="none", ec="none")

    # Plot genomic features
    features = seqid2features[seqid]
    for feature in features:
        if feature.type == "CDS":
            if feature.location.strand == 1:
                f_cds_track.genomic_features(feature, fc=colors['forward_cds'], ec="none")
            else:
                r_cds_track.genomic_features(feature, fc=colors['reverse_cds'], ec="none")
        elif feature.type == "rRNA":
            if feature.location.strand == 1:
                f_cds_track.genomic_features(feature, fc=colors['rrna'], ec="none")
            else:
                r_cds_track.genomic_features(feature, fc=colors['rrna'], ec="none")
        elif feature.type == "tRNA":
            if feature.location.strand == 1:
                f_cds_track.genomic_features(feature, fc=colors['trna'], ec="none")
            else:
                r_cds_track.genomic_features(feature, fc=colors['trna'], ec="none")
    
    # Track 4: GC content
    gc_content_track = sector.add_track((64, 79))
    gc_content_track.axis(fc="none", ec="none")
    
    seq = seqid2seq[seqid]
    pos_list, gc_contents = gbk.calc_gc_content(
        seq=seq, 
        window_size=params['window_size'], 
        step_size=params['step_size']
    )
    gc_contents = gc_contents - gbk.calc_genome_gc_content()
    
    positive_gc_content = np.where(gc_contents > 0, gc_contents, 0)
    negative_gc_content = np.where(gc_contents < 0, gc_contents, 0)
    gc_content_abs_max = np.max(np.abs(gc_contents))
    
    gc_content_track.fill_between(pos_list, positive_gc_content, 0,
                                  vmin=-gc_content_abs_max, vmax=gc_content_abs_max, 
                                  color=colors['gc_content_pos'])
    gc_content_track.fill_between(pos_list, negative_gc_content, 0,
                                  vmin=-gc_content_abs_max, vmax=gc_content_abs_max, 
                                  color=colors['gc_content_neg'])
    
    # Track 5: GC skew
    gc_skew_track = sector.add_track((49, 64))
    gc_skew_track.axis(fc="none", ec="none")
    
    pos_list, gc_skews = gbk.calc_gc_skew(
        seq=seq, 
        window_size=params['window_size'], 
        step_size=params['step_size']
    )
    
    positive_gc_skew = np.where(gc_skews > 0, gc_skews, 0)
    negative_gc_skew = np.where(gc_skews < 0, gc_skews, 0)
    gc_skew_abs_max = np.max(np.abs(gc_skews))
    
    gc_skew_track.fill_between(pos_list, positive_gc_skew, 0,
                               vmin=-gc_skew_abs_max, vmax=gc_skew_abs_max, 
                               color=colors['gc_skew_pos'])
    gc_skew_track.fill_between(pos_list, negative_gc_skew, 0,
                               vmin=-gc_skew_abs_max, vmax=gc_skew_abs_max, 
                               color=colors['gc_skew_neg'])
    
    # Center label with genome size
    display_name = "Buchnera PP" if seqid == "chromosome" else seqid
    genome_size = seqid2size[seqid]
    genome_size_formatted = f"{genome_size:,} bp"

    circos.text(display_name, r=25, size=10, weight='bold')
    circos.text(genome_size_formatted, r=18, size=8, weight='normal')
    
    # Plot
    fig = circos.plotfig(figsize=(params['figsize'], params['figsize']))
    
    # Add legend (only for chromosome)
    if seqid == 'chromosome':
        handles = [
            Patch(color=colors['forward_cds'], label='Forward CDS'),
            Patch(color=colors['reverse_cds'], label='Reverse CDS'),
            Patch(color=colors['rrna'], label='rRNA'),
            Patch(color=colors['trna'], label='tRNA'),
            Patch(color=colors['gc_content_pos'], label='GC Content (+)'),
            Patch(color=colors['gc_content_neg'], label='GC Content (-)'),
            Patch(color=colors['gc_skew_pos'], label='GC Skew (+)'),
            Patch(color=colors['gc_skew_neg'], label='GC Skew (-)'),
        ]
        fig.legend(handles=handles, loc='upper center', bbox_to_anchor=(0.5, 0.02), 
                   ncol=4, fontsize=7, frameon=False)
    
    # Save files
    fig.savefig(f"{species}_{seqid}.png", dpi=300, bbox_inches='tight', transparent=True)
    fig.savefig(f"{species}_{seqid}.svg", bbox_inches='tight', transparent=True)
    plt.close(fig)