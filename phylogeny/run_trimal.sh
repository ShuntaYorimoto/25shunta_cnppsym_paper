#!/bin/sh
#PBS -l select=1:ncpus=1:mpiprocs=1:ompthreads=1
#PBS -l walltime=24:00:00
cd $PBS_O_WORKDIR

source ~/miniconda3/etc/profile.d/conda.sh
conda activate raxml-ng

### configs ###

INDIR=../analysis/250501_mafft
OUTDIR=../analysis/250501_trimal
FileIdxList=`ls $INDIR`
GAPTHRESHOLD=1.0

if [ ! -d "$OUTDIR" ]; then
    mkdir $OUTDIR
fi

###

for i in $FileIdxList
do
    trimal \
	-in $INDIR/$i \
	-out $OUTDIR/`basename $i _mafft.fa`_trimal.fa \
	-gt $GAPTHRESHOLD
done

conda deactivate
