#!/bin/sh
#PBS -l select=1:ncpus=32:mpiprocs=1:ompthreads=32
#PBS -l walltime=24:00:00
cd $PBS_O_WORKDIR

source ~/miniconda3/etc/profile.d/conda.sh
conda activate raxml-ng

### configs ###

NCPUS=32
INDIR=../analysis/250501_phylogeny_Ars
INFILE=concatenated_MSAs.fa
MSAFMT=FASTA
DATATYPE=AA
MODEL=CPREV+I+G4+F
NBS=1000

if [ ! -d $OUTDIR ]; then
    mkdir $OUTDIR
fi

###

raxml-ng \
    --threads $NCPUS \
    --msa $INDIR/$INFILE \
    --msa-format $MSAFMT \
    --data-type $DATATYPE \
    --all \
    --model $MODEL \
    --bs-trees $NBS \
    --prefix $INDIR/`basename $INFILE .fa`_RMLNG \

conda deactivate
