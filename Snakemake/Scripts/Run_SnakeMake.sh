#!/bin/bash

SnakeFile=$1

cores=12
. /n/home13/yasinkaymaz/miniconda3/etc/profile.d/conda.sh
#conda env export -n R3.3 > R3.6.yml
conda activate R3.6

snakemake -k \
  -s $SnakeFile \
  --configfile config.yml \
  --use-singularity \
  --use-conda \
  -j ${cores} \
  --singularity-args '--bind /n/home13/yasinkaymaz/LabSpace/data --bind /n/home13/yasinkaymaz/LabSpace/results/'
