args <- commandArgs(TRUE)

run_scClassify<-function(DataPath,LabelsPath,CV_RDataPath,OutputDir,GeneOrderPath = NULL, NumGenes = NULL, TreeTable = NULL){
  "
  run scClassify
  Wrapper script to run run_scClassify on a benchmark dataset with 5-fold cross validation,
  outputs lists of true and predicted cell labels as csv files, as well as computation time.

  Parameters
  ----------
  DataPath : Data file path (.csv), cells-genes matrix with cell unique barcodes
  as row names and gene names as column names.
  LabelsPath : Cell population annotations file path (.csv).
  CV_RDataPath : Cross validation RData file path (.RData), obtained from Cross_Validation.R function.
  OutputDir : Output directory defining the path of the exported file.
  GeneOrderPath : Gene order file path (.csv) obtained from feature selection,
  defining the genes order for each cross validation fold, default is NULL.
  NumGenes : Number of genes used in case of feature selection (integer), default is NULL.
  TreeTable: a tab delimited file for defining the cell type relationships as a tree topology.
  "

  Data <- read.csv(DataPath, row.names = 1)
  Labels <- as.matrix(read.csv(LabelsPath))
  load(CV_RDataPath)
  Labels <- as.vector(Labels[, col_Index])
  Data <- Data[Cells_to_Keep,]
  Labels <- Labels[Cells_to_Keep]
  if(!is.null(GeneOrderPath) & !is.null (NumGenes)){
    GenesOrder <- read.csv(GeneOrderPath)
  }

  #############################################################################
  #                               scClassify                                  #
  #############################################################################
  library(scClassify)
  True_Labels_scClassify <- list()
  Pred_Labels_scClassify <- list()
  Total_Time_scClassify <- list()
  Data = t(as.matrix(Data))

  for (i in c(1:n_folds)){
    if(!is.null(GeneOrderPath) & !is.null (NumGenes)){
      MatTrain <- as(Data[as.vector(GenesOrder[c(1:NumGenes), i])+1, Train_Idx[[i]]], "dgCMatrix")
      MatTest <- as(Data[as.vector(GenesOrder[c(1:NumGenes), i])+1, Test_Idx[[i]]], "dgCMatrix")
    }
    else{
      MatTrain <- as(Data[, Train_Idx[[i]]], "dgCMatrix")
      MatTest <- as(Data[, Test_Idx[[i]]], "dgCMatrix")
    }

    start_time <- Sys.time()
    scClassify_res <- scClassify(exprsMat_train = MatTrain,
                    cellTypes_train = Labels[Train_Idx[[i]]],
                    exprsMat_test = list(test = MatTest),
                    cellTypes_test = list(testTypes = Labels[Test_Idx[[i]]]),
                    returnList = FALSE,
                    verbose = FALSE)
    end_time <- Sys.time()

    Total_Time_scClassify[i] <- as.numeric(difftime(end_time,start_time,units = 'secs'))
    True_Labels_scClassify[i] <- list(Labels[Test_Idx[[i]]])
    Pred_Labels_scClassify[i] <- list(as.vector(scClassify_res$testRes$test$pearson_WKNN_limma$predRes))
  }
  True_Labels_scClassify <- as.vector(unlist(True_Labels_scClassify))
  Pred_Labels_scClassify <- as.vector(unlist(Pred_Labels_scClassify))
  write.csv(True_Labels_scClassify,paste0(OutputDir,'/scClassify_true.csv'),row.names = FALSE)
  write.csv(Pred_Labels_scClassify,paste0(OutputDir,'/scClassify_pred.csv'),row.names = FALSE)
  write.csv(Total_Time_scClassify,paste0(OutputDir,'/scClassify_total_time.csv'),row.names = FALSE)
}

if (args[6] == "0") {
  run_scClassify(DataPath = args[1], LabelsPath = args[2], CV_RDataPath = args[3], OutputDir = args[4])
} else {
  run_scClassify(DataPath = args[1], LabelsPath = args[2], CV_RDataPath = args[3], OutputDir = args[4], GeneOrderPath = args[5], NumGenes = as.numeric(args[6]))
}
