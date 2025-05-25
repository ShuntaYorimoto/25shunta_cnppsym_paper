#!/bin/sh
#PBS -l select=1:ncpus=32:mpiprocs=1:ompthreads=32
#PBS -l walltime=24:00:00
cd $PBS_O_WORKDIR

### configs ###

source /apl/bio/etc/bio.sh
module load blast+/2.13.0

NCPUS=32
COMMAND=blastn
OUTDIR=../analysis/240531_${COMMAND}
QUERY=../data/Pseudoregma_panicola_HiFi_2runs_reads.fasta
DB=../data/Buchnera_Pectobacterium_genomes.fasta
OUTNAME=`basename $QUERY .fa`.vs.`basename $DB`.${COMMAND}.fmt6.txt

if [ ! -d "$OUTDIR" ]; then
  mkdir $OUTDIR
fi

###

$COMMAND \
    -num_threads $NCPUS \
    -query $QUERY \
    -db $DB \
    -evalue 1e-3 \
    -outfmt 6 \
    > $OUTDIR/$OUTNAME
