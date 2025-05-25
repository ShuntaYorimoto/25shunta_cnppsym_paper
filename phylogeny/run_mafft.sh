#!/bin/sh
#PBS -l select=1:ncpus=4:mpiprocs=1:ompthreads=4
#PBS -l walltime=6:00:00
cd $PBS_O_WORKDIR

source ~/miniconda3/etc/profile.d/conda.sh
conda activate raxml-ng

### configs ###

NCPUS=4
INDIR=../data/OrthoFinder/Results_May01/Single_Copy_Orthologue_Sequences
FileIdxList=`ls $INDIR`
OUTDIR=../analysis/250501_mafft

if [ ! -d "$OUTDIR" ]; then
    mkdir $OUTDIR
fi

###

for i in $FileIdxList
do
    mafft-linsi \
	--thread $NCPUS \
	$INDIR/$i \
	> $OUTDIR/`basename $i .fa`_mafft.fa
done

conda deactivate
