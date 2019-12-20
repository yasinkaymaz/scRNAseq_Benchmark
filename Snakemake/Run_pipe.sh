#!/bin/bash

WORK_DIR=$1
cores=12

. /n/home13/yasinkaymaz/miniconda3/etc/profile.d/conda.sh
#conda env export -n R3.3 > R3.6.yml

cd $WORK_DIR
dir=`pwd`
SAMPLE_NAME=`basename $dir`

ln -s ~/codes/scRNAseq_Benchmark/Snakemake/Scripts ./
#Modify the config file

sbatch -p holy-info \
-n ${cores} \
-w holy2c0529 \
--mem 256000 \
-t 6-0:00 \
--job-name=BM_"$SAMPLE_NAME" \
-e err_"$SAMPLE_NAME".%j.txt \
-o out_"$SAMPLE_NAME".%j.txt \
snakemake -k \
  -s ~/codes/scRNAseq_Benchmark/Snakemake/Snakefile \
  --configfile config.yml \
  --use-singularity \
  --use-conda \
  -j ${cores} \
  --singularity-args '--bind /n/home13/yasinkaymaz/LabSpace/data --bind /n/home13/yasinkaymaz/LabSpace/results/'
  #
  # - HieRFIT
  # - CHETAH
  # - SingleR
  # - scID
  # - scmapcluster
  # - scmapcell
  # - singleCellNet
  # - kNN50
  # - kNN9
  # - scVI
  # - LDA
  # - LDA_rejection
  # - NMC
  # - RF
  # - SVM
  # - SVM_rejection
  # - Seurat
  # - scPred
  # - CaSTLe
  # - LAmbDA
  # - ACTINN
  # - Cell_BLAST
