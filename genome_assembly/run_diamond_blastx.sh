#!/bin/sh
#PBS -q medium
#PBS -l ncpus=40
#PBS -l mem=48gb
cd $PBS_O_WORKDIR

### configs ###

source /etc/profile.d/modules.sh
module load diamond/2.0.15

NCPUS=40
COMMAND=blastx
OUTDIR=../analysis/240514_diamond_${COMMAND}
#QUERY=
DB=../data/Buchnera_Pectobacterium_prot.dmnd
OUTNAME=`basename $QUERY .fa`.vs.`basename $DB`.diamond_${COMMAND}.fmt6.txt

if [ ! -d "$OUTDIR" ]; then
  mkdir $OUTDIR
fi

###

diamond $COMMAND \
  --query $QUERY \
  --db $DB \
  --threads $NCPUS \
  --outfmt 6 \
  --long-reads \
  > $OUTDIR/$OUTNAME
