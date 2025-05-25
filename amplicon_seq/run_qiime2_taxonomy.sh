#!/bin/bash
#PBS -q small
#PBS -l mem=20gb
cd $PBS_O_WORKDIR

source ~/miniconda3/etc/profile.d/conda.sh
conda activate qiime2-2020.8

### CONFIGS ###
IDX=Ceratovacuna_cerbera_F17R21
READ=${IDX}_rep-seqs-dada2.qza
TABLE=${IDX}_table-dada2.qza
INDIR=../analysis/240421_qiime2_dada2
OUTDIR=../analysis/240421_qiime2_taxonomy
DB=../../database/silva-138-99-nb-classifier.qza
META=sample-metadata.tsv
if [ ! -d $OUTDIR ]; then
  mkdir $OUTDIR
fi
###

qiime feature-classifier classify-sklearn \
  --i-classifier $DB \
  --i-reads $INDIR/$READ \
  --o-classification $OUTDIR/${IDX}_taxonomy.qza

qiime metadata tabulate \
  --m-input-file $OUTDIR/${IDX}_taxonomy.qza \
  --o-visualization $OUTDIR/${IDX}_taxonomy.qzv

qiime taxa barplot \
  --i-table $INDIR/$TABLE \
  --i-taxonomy $OUTDIR/${IDX}_taxonomy.qza \
  --m-metadata-file $META \
  --o-visualization $OUTDIR/${IDX}_taxa-bar-plots.qzv

conda deactivate
