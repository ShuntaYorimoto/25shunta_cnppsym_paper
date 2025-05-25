#!/bin/sh
#PBS -l select=1:ncpus=4:mpiprocs=1:ompthreads=4
#PBS -l walltime=8:00:00
cd $PBS_O_WORKDIR

source ~/miniconda3/etc/profile.d/conda.sh
conda activate raxml-ng

### configs ###

NCPUS=4
INDIR=../analysis/250501_phylogeny_Ars
INFILE=concatenated_MSAs.fa
DATATYPE=aa

###

modeltest-ng \
    --processes $NCPUS \
    --datatype $DATATYPE \
    --input $INDIR/$INFILE \
    --output $INDIR/`basename $INFILE .fa`_MTNG

conda deactivate
