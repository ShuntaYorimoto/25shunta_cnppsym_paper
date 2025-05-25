#!/bin/bash
#PBS -q small
cd $PBS_O_WORKDIR

source ~/miniconda3/etc/profile.d/conda.sh
conda activate qiime2-2020.8

### CONFIGS ###
INDIR=../data/Ceratovacuna_cerbera
IDX=`basename $INDIR`
OUTDIR=../analysis/240421_qiime2_imported
if [ ! -d $OUTDIR ]; then
  mkdir $OUTDIR
fi
###

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path $INDIR \
  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
  --output-path $OUTDIR/${IDX}.qza

qiime demux summarize \
  --i-data $OUTDIR/${IDX}.qza \
  --o-visualization $OUTDIR/${IDX}.qzv

conda deactivate
