#!/bin/bash
#PBS -q small
#PBS -l ncpus=4
#PBS -l mem=5gb
cd $PBS_O_WORKDIR

source ~/miniconda3/etc/profile.d/conda.sh
conda activate qiime2-2020.8

### CONFIGS ###

DATE=240421
INDIR=../analysis/${DATE}_qiime2_imported
OUTDIR=../analysis/${DATE}_qiime2_dada2

if [ ! -d $OUTDIR ]; then
  mkdir $OUTDIR
fi

IDX=Ceratovacuna_cerbera
F5E=17
R5E=21
TRIM=F${F5E}R${R5E}
F3E=250
R3E=250
TOOL=dada2
METHOD=denoise-paired

###

qiime $TOOL $METHOD \
    --i-demultiplexed-seqs $INDIR/${IDX}.qza \
    --p-trim-left-f $F5E \
    --p-trim-left-r $R5E \
    --p-trunc-len-f $F3E \
    --p-trunc-len-r $R3E \
    --p-n-threads $NCPUS \
    --o-representative-sequences $OUTDIR/${IDX}_${TRIM}_rep-seqs-${TOOL}.qza \
    --o-table $OUTDIR/${IDX}_${TRIM}_table-${TOOL}.qza \
    --o-denoising-stats $OUTDIR/${IDX}_${TRIM}_stats-${TOOL}.qza

qiime metadata tabulate \
    --m-input-file $OUTDIR/${IDX}_${TRIM}_stats-${TOOL}.qza \
    --o-visualization $OUTDIR/${IDX}_${TRIM}_stats-${TOOL}.qzv

qiime feature-table summarize \
    --i-table $OUTDIR/${IDX}_${TRIM}_table-${TOOL}.qza \
    --o-visualization $OUTDIR/${IDX}_${TRIM}_table-${TOOL}.qzv

qiime feature-table tabulate-seqs \
    --i-data $OUTDIR/${IDX}_${TRIM}_rep-seqs-${TOOL}.qza \
    --o-visualization $OUTDIR/${IDX}_${TRIM}_rep-seqs-${TOOL}.qzv

conda deactivate
