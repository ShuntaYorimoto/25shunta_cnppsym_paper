#!/bin/sh
#PBS -l select=1:ncpus=8:mpiprocs=1:ompthreads=8
#PBS -l walltime=24:00:00
cd ${PBS_O_WORKDIR}

### configs ###

source /apl/bio/etc/bio.sh
module load blast+/2.13.0

NCPUS=8
COMMAND=blastp
OUTFMT=6
MAXTARGETSEQS=5
EVALUE=1e-3
#QUERY=
DB=../data/SyPpEd_modified
OUTDIR=../analysis/250428_blastp
OUTFILE=`basename $QUERY .faa`_to_`basename $DB`_${COMMAND}.fmt${OUTFMT}.txt

if [ ! -d "$OUTDIR" ]; then
  mkdir $OUTDIR
fi

###

$COMMAND \
    -query $QUERY \
    -db $DB \
    -outfmt $OUTFMT \
    -max_target_seqs $MAXTARGETSEQS \
    -evalue $EVALUE \
    -num_threads $NCPUS \
    > $OUTDIR/$OUTFILE
