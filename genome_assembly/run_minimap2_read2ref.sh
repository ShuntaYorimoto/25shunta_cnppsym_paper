#!/bin/sh
#PBS -l select=1:ncpus=32:mpiprocs=1:ompthreads=32
#PBS -l walltime=24:00:00
cd $PBS_O_WORKDIR

### configs ###

source /apl/bio/etc/bio.sh
module load minimap2/2.24
module load samtools/1.19.2

PRESET=map-hifi
NCPUS=32
REF=../analysis/240531_metaMDBG/contigs.fasta
READ=../data/Pseudoregma_panicola_HiFi_2runs_reads.fastq.gz
OUTF=`basename $READ .fastq.gz`_to_`basename $REF .fasta`
OUTDIR=../analysis/240531_metaMDBG

if [ ! -d "$OUTDIR" ]; then
  mkdir $OUTDIR
fi

###

minimap2 \
    -ax $PRESET \
    -t $NCPUS \
    $REF \
    $READ \
    > $OUTDIR/${OUTF}.sam \

samtools sort \
	 -@ $NCPUS \
	 -o $OUTDIR/${OUTF}_sorted.bam \
	 $OUTDIR/${OUTF}.sam \

samtools index \
	 -@ $NCPUS \
	 $OUTDIR/${OUTF}_sorted.bam

rm $OUTDIR/${OUTF}.sam

