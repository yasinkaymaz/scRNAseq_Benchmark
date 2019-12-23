#!/bin/bash

WORK_DIR=$1
SnakeFile=$2
cd $WORK_DIR
cores=12
dir=`pwd`
SAMPLE_NAME=`basename $dir`

ln -s ~/codes/scRNAseq_Benchmark/Snakemake/Scripts ./
#Modify the config file

rm -r .snakemake/

sbatch -p serial_requeue \
-n ${cores} \
--mem 256000 \
-t 6-0:00 \
--job-name=BM_"$SAMPLE_NAME" \
-e err_"$SAMPLE_NAME".%j.txt \
-o out_"$SAMPLE_NAME".%j.txt Scripts/Run_SnakeMake.sh $SnakeFile

#' bash ~/codes/scRNAseq_Benchmark/Snakemake/Run_pipe.sh /n/home13/yasinkaymaz/scratchSpace02/benchmarking/PbmcBench/10Xv2 ~/codes/scRNAseq_Benchmark/Snakemake/Interdata.Snakefile
