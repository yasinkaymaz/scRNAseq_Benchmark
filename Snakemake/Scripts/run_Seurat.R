args <- commandArgs(TRUE)

run_Seurat<-function(DataPath,LabelsPath,CV_RDataPath,OutputDir,GeneOrderPath = NULL, NumGenes = NULL){
  "
  run Seurat
  Wrapper script to run run_Seurat on a benchmark dataset with 5-fold cross validation,
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

  #Function for Seurat Anchor prediction
  SeuratAnchorPredict <- function(ref, query){
    transfer.anchors <- FindTransferAnchors(reference = refSeu, query = queSeu, features = VariableFeatures(object = refSeu),
                                          reference.assay = "RNA", query.assay = "RNA", reduction = "pcaproject")
                                          celltype.predictions <- TransferData(anchorset = transfer.anchors, refdata = refSeu$CellType, dims = 1:30)
    return(celltype.predictions)
  }

  #############################################################################
  #                               Seurat                                     #
  #############################################################################
  library(Seurat)
  True_Labels_Seurat <- list()
  Pred_Labels_Seurat <- list()
  Total_Time_Seurat <- list()
  Data = t(as.matrix(Data))

    for (i in c(1:n_folds)){
      celltype.predictions <- rep("NA", times=length(list(Labels[Test_Idx[[i]]])[[1]]))

      if(!is.null(GeneOrderPath) & !is.null (NumGenes)){

        start_time <- Sys.time()

        refdata <- Data[as.vector(GenesOrder[c(1:NumGenes),i])+1,Train_Idx[[i]]]
        refSeu <- CreateSeuratObject(counts = refdata)
        refSeu@meta.data$CellType <- Labels[Train_Idx[[i]]]

        quedata <- Data[as.vector(GenesOrder[c(1:NumGenes),i])+1,Test_Idx[[i]]]
        queSeu <- CreateSeuratObject(counts = quedata)
        queSeu@meta.data$CellType <- Labels[Test_Idx[[i]]]

        refSeu <- UpdateSeuratObject(object = refSeu)
        refSeu <- FindVariableFeatures(refSeu, selection.method = "vst", nfeatures = 2000)

        celltype.predictions <- SeuratAnchorPredict(ref=refSeu, query = queSeu)

        end_time <- Sys.time()
      }
      else{
        start_time <- Sys.time()

        refdata <- Data[,Train_Idx[[i]]]
        refSeu <- CreateSeuratObject(counts = refdata)
        refSeu@meta.data$CellType <- Labels[Train_Idx[[i]]]

        quedata <- Data[,Test_Idx[[i]]]
        queSeu <- CreateSeuratObject(counts = quedata)
        queSeu@meta.data$CellType <- Labels[Test_Idx[[i]]]

        refSeu <- UpdateSeuratObject(object = refSeu)
        refSeu <- FindVariableFeatures(refSeu, selection.method = "vst", nfeatures = 2000)

        tryCatch(celltype.predictions <- SeuratAnchorPredict(ref=refSeu, query = queSeu), error = function(e){print("Finding anchors fails ..."); NaN})

        end_time <- Sys.time()
      }
      Total_Time_Seurat[i] <- as.numeric(difftime(end_time,start_time,units = 'secs'))

      True_Labels_Seurat[i] <- list(Labels[Test_Idx[[i]]])
      Pred_Labels_Seurat[i] <- list(as.vector(celltype.predictions$predicted.id))
    }
    True_Labels_Seurat <- as.vector(unlist(True_Labels_Seurat))
    Pred_Labels_Seurat <- as.vector(unlist(Pred_Labels_Seurat))
    Total_Time_Seurat <- as.vector(unlist(Total_Time_Seurat))

    write.csv(True_Labels_Seurat,paste0(OutputDir,'/Seurat_true.csv'),row.names = FALSE)
    write.csv(Pred_Labels_Seurat,paste0(OutputDir,'/Seurat_pred.csv'),row.names = FALSE)
    write.csv(Total_Time_Seurat,paste0(OutputDir,'/Seurat_total_time.csv'),row.names = FALSE)

}

if (args[6] == "0") {
  run_Seurat(DataPath = args[1], LabelsPath = args[2], CV_RDataPath = args[3], OutputDir = args[4])
} else {
  run_Seurat(DataPath = args[1], LabelsPath = args[2], CV_RDataPath = args[3], OutputDir = args[4], GeneOrderPath = args[5], NumGenes = as.numeric(args[6]))
}
