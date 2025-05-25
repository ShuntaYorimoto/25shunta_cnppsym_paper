#!/bin/sh
#PBS -l select=1:ncpus=8:mpiprocs=1:ompthreads=8
#PBS -l walltime=8:00:00
cd $PBS_O_WORKDIR

source ~/miniconda3/etc/profile.d/conda.sh
conda activate dfast

### configs ###

GENOME=../../240430_PpanSymbiontGenomeAssembly/analysis/240514_metamdbg/SyPp_genome3.fa
GENUS=Symbiopectobacterium
SPECIES=sp.
STRAIN=Pp_OKZK
OUTDIR=../analysis/250425_${GENUS}_dfast
COMPLETE=f
LOCTAG=SymCn_OKZK
NCPUS=8

###

dfast \
    --genome $GENOME \
    --out $OUTDIR \
    --organism ${GENUS}_${SPECIES} \
    --strain $STRAIN \
    --complete $COMPLETE \
    --locus_tag_prefix $LOCTAG \
    --cpu $NCPUS \
    --force

conda deactivate
