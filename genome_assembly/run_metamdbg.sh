#!/bin/sh
#PBS -l select=1:ncpus=32:mpiprocs=1:ompthreads=32
#PBS -l walltime=24:00:00
cd $PBS_O_WORKDIR

### configs ###

source ~/miniconda3/etc/profile.d/conda.sh
conda activate metaMDBG

NCPUS=32
READ=../data/Pseudoregma_panicola_HiFi_2runs_reads_NuclProtBased_onlySymbiont.fastq.gz
OUTDIR=../analysis/240531_metaMDBG

if [ ! -d "$OUTDIR" ]; then
  mkdir $OUTDIR
fi

###

metaMDBG asm \
  $OUTDIR \
  $READ \
  -t $NCPUS

conda deactivate
