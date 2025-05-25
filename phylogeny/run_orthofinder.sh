#!/bin/sh
#PBS -l select=1:ncpus=32:mpiprocs=1:ompthreads=32
#PBS -l walltime=24:00:00
cd $PBS_O_WORKDIR

source ~/miniconda3/etc/profile.d/conda.sh
conda activate orthofinder

### configs ###

DIR=../data
NCPUS=32

###

orthofinder \
    -f $DIR \
    -t $NCPUS

conda deactivate
