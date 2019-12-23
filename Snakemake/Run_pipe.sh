#!/bin/bash

WORK_DIR=$1
cores=12


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
Scripts/Run_SnakeMake.sh $cores
