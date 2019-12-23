dockerTag = "latest" #FIXME tagged versions

def feature_ranking(w):
    if "feature_ranking" in config.keys():
        return config["feature_ranking"]
    else:
        return "{output_dir}/rank_genes_dropouts.csv".format(
            output_dir=w.output_dir)

"""
One rule to... rule... them all...
"""
rule all:
  input:
    tool_outputs = expand(
        "{output_dir}/evaluation/{measure}/{tool}.csv",
        tool=config["tools_to_run"],
        output_dir=config["output_dir"],
        measure=["Confusion", "F1", "PopSize", "Summary"])


"""
Rule for the result evaluation
"""
rule evaluate:
  input:
    true="{output_dir}/{tool}/{tool}_true.csv",
    pred="{output_dir}/{tool}/{tool}_pred.csv"
  output:
    "{output_dir}/evaluation/Confusion/{tool}.csv",
    "{output_dir}/evaluation/F1/{tool}.csv",
    "{output_dir}/evaluation/PopSize/{tool}.csv",
    "{output_dir}/evaluation/Summary/{tool}.csv",
  log: "{output_dir}/evaluation/{tool}.log"
  singularity: "docker://scrnaseqbenchmark/baseline:{}".format(dockerTag)
  shell:
    "Rscript Scripts/evaluate.R "
    "{input.true} "
    "{input.pred} "
    "{wildcards.output_dir}/evaluation "
    "{wildcards.tool} "
    "&> {log}"


"""
Rule for creating cross validation folds
"""
# rule generate_CV_folds:
#   input: config["labfile"],
#   output: "{output_dir}/CV_folds.RData"
#   log: "{output_dir}/CV_folds.log"
#   params:
#     column = config.get("column", 1) # default to 1
#   singularity: "docker://scrnaseqbenchmark/cross_validation:{}".format(dockerTag)
#   shell:
#     "Rscript Scripts/Cross_Validation.R "
#     "{input} "
#     "{params.column} "
#     "{wildcards.output_dir} "
#     "&> {log}"


"""
Rule for creating feature rank lists
"""
rule generate_dropouts_feature_rankings:
    input:
        datafile = config["datafile"],
        folds = config["FoldData"]
    output: "{output_dir}/rank_genes_dropouts.csv"
    log: "{output_dir}/rank_genes_dropouts.log"
    singularity: "docker://scrnaseqbenchmark/baseline:{}".format(dockerTag)
    shell:
        "echo test > {wildcards.output_dir}/test\n"
        "python3 Scripts/rank_gene_dropouts.py "
        "{input.datafile} "
        "{input.folds} "
        "{wildcards.output_dir} "
        "&> {log}"


"""
Rule for R based tools.
"""
rule singleCellNet:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/singleCellNet/singleCellNet_pred.csv",
    true = "{output_dir}/singleCellNet/singleCellNet_true.csv",
    test_time = "{output_dir}/singleCellNet/singleCellNet_test_time.csv",
    training_time = "{output_dir}/singleCellNet/singleCellNet_training_time.csv"
  log: "{output_dir}/singleCellNet/singleCellNet.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/singlecellnet:{}".format(dockerTag)
  shell:
    "Rscript Scripts/run_singleCellNet.R "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/singleCellNet "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule scmapcell:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/scmapcell/scmapcell_pred.csv",
    true = "{output_dir}/scmapcell/scmapcell_true.csv",
    test_time = "{output_dir}/scmapcell/scmapcell_test_time.csv",
    training_time = "{output_dir}/scmapcell/scmapcell_training_time.csv"
  log: "{output_dir}/scmapcell/scmapcell.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/scmap:{}".format(dockerTag)
  shell:
    "Rscript Scripts/run_scmapcell.R "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/scmapcell "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule scmapcluster:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/scmapcluster/scmapcluster_pred.csv",
    true = "{output_dir}/scmapcluster/scmapcluster_true.csv",
    test_time = "{output_dir}/scmapcluster/scmapcluster_test_time.csv",
    training_time = "{output_dir}/scmapcluster/scmapcluster_training_time.csv"
  log: "{output_dir}/scmapcluster/scmapcluster.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/scmap:{}".format(dockerTag)
  shell:
    "Rscript Scripts/run_scmapcluster.R "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/scmapcluster "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule scID:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/scID/scID_pred.csv",
    true = "{output_dir}/scID/scID_true.csv",
    total_time = "{output_dir}/scID/scID_total_time.csv"
  log: "{output_dir}/scID/scID.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/scid:{}".format(dockerTag)
  shell:
    "Rscript Scripts/run_scID.R "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/scID "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule CHETAH:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/CHETAH/CHETAH_pred.csv",
    true = "{output_dir}/CHETAH/CHETAH_true.csv",
    total_time = "{output_dir}/CHETAH/CHETAH_total_time.csv"
  log: "{output_dir}/CHETAH/CHETAH.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/chetah:{}".format(dockerTag)
  shell:
    "Rscript Scripts/run_CHETAH.R "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/CHETAH "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule SingleR:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/SingleR/SingleR_pred.csv",
    true = "{output_dir}/SingleR/SingleR_true.csv",
    total_time = "{output_dir}/SingleR/SingleR_total_time.csv"
  log: "{output_dir}/SingleR/SingleR.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/singler:{}".format(dockerTag)
  shell:
    "Rscript Scripts/run_SingleR.R "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/SingleR "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule HieRFIT:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/HieRFIT/HieRFIT_pred.csv",
    true = "{output_dir}/HieRFIT/HieRFIT_true.csv",
    test_time = "{output_dir}/HieRFIT/HieRFIT_test_time.csv",
    training_time = "{output_dir}/HieRFIT/HieRFIT_training_time.csv"
  log: "{output_dir}/HieRFIT/HieRFIT.log"
  params:
    n_features = config.get("number_of_features", 0),
    treefile = config["treefile"]
  #singularity: "docker://yasinkaymaz/hierfit:{}".format("d0.02")
  conda: "R3.6.yml"
  shell:
    "Rscript Scripts/run_HieRFIT.R "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/HieRFIT "
    "{input.ranking} "
    "{params.n_features} "
    "{params.treefile}"
    "&> {log}"

rule Seurat:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/Seurat/Seurat_pred.csv",
    true = "{output_dir}/Seurat/Seurat_true.csv",
    total_time = "{output_dir}/Seurat/Seurat_total_time.csv"
  log: "{output_dir}/Seurat/Seurat.log"
  params:
    n_features = config.get("number_of_features", 0)
  conda: "R3.6.yml"
  shell:
    "Rscript Scripts/run_Seurat.R "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/Seurat "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule scPred:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/scPred/scPred_pred.csv",
    true = "{output_dir}/scPred/scPred_true.csv",
    test_time = "{output_dir}/scPred/scPred_test_time.csv",
    training_time = "{output_dir}/scPred/scPred_training_time.csv"
  log: "{output_dir}/scPred/scPred.log"
  params:
    n_features = config.get("number_of_features", 0)
  conda: "R3.6.yml"
  shell:
    "Rscript Scripts/run_scPred.R "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/scPred "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule CaSTLe:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/CaSTLe/CaSTLe_pred.csv",
    true = "{output_dir}/CaSTLe/CaSTLe_true.csv",
    test_time = "{output_dir}/CaSTLe/CaSTLe_test_time.csv",
    training_time = "{output_dir}/CaSTLe/CaSTLe_training_time.csv"
  log: "{output_dir}/CaSTLe/CaSTLe.log"
  params:
    n_features = config.get("number_of_features", 0)
  conda: "R3.6.yml"
  shell:
    "Rscript Scripts/run_CaSTLe.R "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/CaSTLe "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"


#NOTE non-conformant to the rest of the rules.
rule Garnett_CV:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    genes_names = config.get("genes", "UNSPECIFIEDFILE"),
    markers = config.get("Garnett_CV", {}).get(
        "markers", "UNSPECIFIEDFILE")
  output:
    pred = "{output_dir}/Garnett_CV/Garnett_CV_pred.csv",
    true = "{output_dir}/Garnett_CV/Garnett_CV_true.csv",
    test_time = "{output_dir}/Garnett_CV/Garnett_CV_test_time.csv",
    training_time = "{output_dir}/Garnett_CV/Garnett_CV_training_time.csv"
  log: "{output_dir}/Garnett_CV/Garnett_CV.log"
  params:
    human = "T" if config.get("human", True) else "F"
  singularity: "docker://scrnaseqbenchmark/garnett:{}".format(dockerTag)
  shell:
    "Rscript Scripts/run_Garnett_CV.R "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{input.genes_names} "
    "{input.markers} "
    "{wildcards.output_dir}/Garnett_CV "
    "{params.human} "
    "&> {log}"

#NOTE non-conformant to the rest of the rules.
rule Garnett_Pretrained: #TODO test this
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    genes_names = config.get("genes", "UNSPECIFIEDFILE"),
    classifier = config.get("Garnett_Pretrained", {}).get(
        "classifier", "UNSPECIFIEDFILE")
  output:
    pred = "{output_dir}/Garnett_Pretrained/Garnett_Pretrained_pred.csv",
    true = "{output_dir}/Garnett_Pretrained/Garnett_Pretrained_true.csv",
    test_time = "{output_dir}/Garnett_Pretrained/Garnett_Pretrained_test_time.csv"
  log: "{output_dir}/Garnett_Pretrained/Garnett_Pretrained.log"
  params:
    human = "T" if config.get("human", True) else "F"
  singularity: "docker://scrnaseqbenchmark/garnett:{}".format(dockerTag)
  shell:
    "Rscript Scripts/run_Garnett_Pretrained.R "
    "{input.datafile} "
    "{input.labfile} "
    "{input.genes_names} "
    "{input.folds} "
    "{input.classifier} "
    "{wildcards.output_dir}/Garnett_Pretrained "
    "{params.human} "
    "&> {log}"


"""
Rules for python based tools.##################################################
"""
rule Moana: #TODO test this
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking,
    classifier = config.get("Moana", {}).get(
        "classifier", "UNSPECIFIEDFILE")
  output:
    pred = "{output_dir}/Moana/Moana_pred.csv",
    true = "{output_dir}/Moana/Moana_true.csv",
    total_time = "{output_dir}/Moana/Moana_total_time.csv"
  log: "{output_dir}/Moana/Moana.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://yasinkaymaz/moana:{}".format('d0.01')
  shell:
    "python3 Scripts/run_moana.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.classifier} "
    "{wildcards.output_dir}/Moana "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"


rule kNN50:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/kNN50/kNN50_pred.csv",
    true = "{output_dir}/kNN50/kNN50_true.csv",
    test_time = "{output_dir}/kNN50/kNN50_test_time.csv",
    training_time = "{output_dir}/kNN50/kNN50_training_time.csv"
  log: "{output_dir}/kNN50/kNN50.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/baseline:{}".format(dockerTag)
  shell:
    "python3 Scripts/run_kNN50.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/kNN50 "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule kNN9:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/kNN9/kNN9_pred.csv",
    true = "{output_dir}/kNN9/kNN9_true.csv",
    test_time = "{output_dir}/kNN9/kNN9_test_time.csv",
    training_time = "{output_dir}/kNN9/kNN9_training_time.csv"
  log: "{output_dir}/kNN9/kNN9.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/baseline:{}".format(dockerTag)
  shell:
    "python3 Scripts/run_kNN9.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/kNN9 "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule Cell_BLAST:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/Cell_BLAST/Cell_BLAST_pred.csv",
    true = "{output_dir}/Cell_BLAST/Cell_BLAST_true.csv",
    test_time = "{output_dir}/Cell_BLAST/Cell_BLAST_test_time.csv",
    training_time = "{output_dir}/Cell_BLAST/Cell_BLAST_training_time.csv"
  log: "{output_dir}/Cell_BLAST/Cell_BLAST.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://yasinkaymaz/cell_blast:v0.2.14"
  shell:
    "python3 Scripts/run_Cell_BLAST.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/Cell_BLAST "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule scVI:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/scVI/scVI_pred.csv",
    true = "{output_dir}/scVI/scVI_true.csv",
    test_time = "{output_dir}/scVI/scVI_test_time.csv",
    training_time = "{output_dir}/scVI/scVI_training_time.csv"
  log: "{output_dir}/scVI/scVI.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/scvi:{}".format(dockerTag)
  shell:
    "python3 Scripts/run_scVI.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/scVI "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule LDA:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/LDA/LDA_pred.csv",
    true = "{output_dir}/LDA/LDA_true.csv",
    test_time = "{output_dir}/LDA/LDA_test_time.csv",
    training_time = "{output_dir}/LDA/LDA_training_time.csv"
  log: "{output_dir}/LDA/LDA.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/baseline:{}".format(dockerTag)
  shell:
    "python3 Scripts/run_LDA.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/LDA "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule LDA_rejection:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/LDA_rejection/LDA_rejection_pred.csv",
    true = "{output_dir}/LDA_rejection/LDA_rejection_true.csv",
    test_time = "{output_dir}/LDA_rejection/LDA_rejection_test_time.csv",
    training_time = "{output_dir}/LDA_rejection/LDA_rejection_training_time.csv"
  log: "{output_dir}/LDA_rejection/LDA_rejection.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/baseline:{}".format(dockerTag)
  shell:
    "python3 Scripts/run_LDA_rejection.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/LDA_rejection "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule NMC:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/NMC/NMC_pred.csv",
    true = "{output_dir}/NMC/NMC_true.csv",
    test_time = "{output_dir}/NMC/NMC_test_time.csv",
    training_time = "{output_dir}/NMC/NMC_training_time.csv"
  log: "{output_dir}/NMC/NMC.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/baseline:{}".format(dockerTag)
  shell:
    "python3 Scripts/run_NMC.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/NMC "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule RF:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/RF/RF_pred.csv",
    true = "{output_dir}/RF/RF_true.csv",
    test_time = "{output_dir}/RF/RF_test_time.csv",
    training_time = "{output_dir}/RF/RF_training_time.csv"
  log: "{output_dir}/RF/RF.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/baseline:{}".format(dockerTag)
  shell:
    "python3 Scripts/run_RF.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/RF "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule SVM:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/SVM/SVM_pred.csv",
    true = "{output_dir}/SVM/SVM_true.csv",
    test_time = "{output_dir}/SVM/SVM_test_time.csv",
    training_time = "{output_dir}/SVM/SVM_training_time.csv"
  log: "{output_dir}/SVM/SVM.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/baseline:{}".format(dockerTag)
  shell:
    "python3 Scripts/run_SVM.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/SVM "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule SVM_rejection:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/SVM_rejection/SVM_rejection_pred.csv",
    true = "{output_dir}/SVM_rejection/SVM_rejection_true.csv",
    test_time = "{output_dir}/SVM_rejection/SVM_rejection_test_time.csv",
    training_time = "{output_dir}/SVM_rejection/SVM_rejection_training_time.csv"
  log: "{output_dir}/SVM_rejection/SVM_rejection.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://scrnaseqbenchmark/baseline:{}".format(dockerTag)
  shell:
    "python3 Scripts/run_SVM_rejection.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/SVM_rejection "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule LAmbDA:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/LAmbDA/LAmbDA_pred.csv",
    true = "{output_dir}/LAmbDA/LAmbDA_true.csv",
    test_time = "{output_dir}/LAmbDA/LAmbDA_test_time.csv",
    training_time = "{output_dir}/LAmbDA/LAmbDA_training_time.csv"
  log: "{output_dir}/LAmbDA/LAmbDA.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://yasinkaymaz/lambda:d0.01"
  shell:
    "python3 Scripts/run_LAmbDA.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/LAmbDA "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"

rule ACTINN:
  input:
    datafile = config["datafile"],
    labfile = config["labfile"],
    folds = config["FoldData"],
    ranking = feature_ranking
  output:
    pred = "{output_dir}/ACTINN/ACTINN_pred.csv",
    true = "{output_dir}/ACTINN/ACTINN_true.csv",
    total_time = "{output_dir}/ACTINN/ACTINN_total_time.csv"
  log: "{output_dir}/ACTINN/ACTINN.log"
  params:
    n_features = config.get("number_of_features", 0)
  singularity: "docker://yasinkaymaz/actinn:d0.01"
  shell:
    "python3 Scripts/run_ACTINN.py "
    "{input.datafile} "
    "{input.labfile} "
    "{input.folds} "
    "{wildcards.output_dir}/ACTINN "
    "{input.ranking} "
    "{params.n_features} "
    "&> {log}"
