


mkdir test
cd test
ln -s ~/codes/scRNAseq_Benchmark/Snakemake/Scripts ./
cp ~/codes/scRNAseq_Benchmark/Snakemake/config.yml ./
cp ~/codes/scRNAseq_Benchmark/Snakemake/*.R ./
cp ~/codes/scRNAseq_Benchmark/Snakemake/rank_gene_dropouts.py ./
#mv example.config.yml config.yml
#Modify the config file

conda activate R3.6

snakemake -k \
  -s ~/codes/scRNAseq_Benchmark/Snakemake/Snakefile \
  --configfile config.yml \
  --use-singularity \
  --singularity-args '--bind /n/home13/yasinkaymaz/LabSpace/data --bind /n/home13/yasinkaymaz/LabSpace/results/'
