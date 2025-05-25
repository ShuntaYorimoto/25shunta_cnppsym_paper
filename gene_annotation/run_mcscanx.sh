#!/bin/sh
#PBS -l select=1:ncpus=1:mpiprocs=1:ompthreads=1
#PBS -l walltime=6:00:00
cd ${PBS_O_WORKDIR}

### configs ###

COMMAND=~/software/MCScanX/MCScanX
PREFIX=../analysis/250428_mcscanx/SyPpEd
GAP_PENALTY=-1
MATCH_SIZE=2
EVALUE=1e-03
MAX_GAPS=5
OVERLAP_WINDOW=10

###

$COMMAND \
    $PREFIX \
    -g $GAP_PENALTY \
    -s $MATCH_SIZE \
    -e $EVALUE \
    -m $MAX_GAPS \
    -w $OVERLAP_WINDOW
