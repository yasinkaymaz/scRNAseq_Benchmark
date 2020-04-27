args <- commandArgs(TRUE)

run_HieRFIT<-function(DataPath,LabelsPath,CV_RDataPath,OutputDir,GeneOrderPath = NULL, NumGenes = NULL, TreeTable = NULL){
  "
  run HieRFIT
  Wrapper script to run run_HieRFIT on a benchmark dataset with 5-fold cross validation,
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
  #                               HieRFIT                                     #
  #############################################################################
  library(HieRFIT)
  True_Labels_HieRFIT <- list()
  Pred_Labels_HieRFIT <- list()
  Train_Time_HieRFIT <- list()
  Test_Time_HieRFIT <- list()
  Data = t(as.matrix(Data))

  exp <- apply(Data, 2, function(x) (x/sum(x))*10000)
  Data <- log1p(exp)

  for (i in c(1:n_folds)){

    if(!is.null(GeneOrderPath) & !is.null (NumGenes)){
      start_traintime <- Sys.time()
      #Here Create HierMod:
      if(!file.exists(TreeTable)){
        treetable <- NULL
        threadN <- CreateDeNovoTree(Data[as.vector(GenesOrder[c(1:NumGenes), i])+1, Train_Idx[[i]]], Labels[Train_Idx[[i]]])$Nnode
        print("User tree is not found! Creating a tree from data...")
      }else{
        treetable <- read.delim(TreeTable, header=F)
        threadN <- CreateTree(treeTable=treetable)$Nnode
      }
      hiermodFile=paste(OutputDir, "/", i, "_HieRMod.Rdata.RDS", sep = "")
      if(!file.exists(hiermodFile)){
        HieRMod <- CreateHieR(RefData = Data[as.vector(GenesOrder[c(1:NumGenes), i])+1, Train_Idx[[i]]],
                              ClassLabels = Labels[Train_Idx[[i]]],
                              Tree = treetable,
                              thread = threadN,
                              species = "mmusculus")
        end_traintime <- Sys.time()
        SaveHieRMod(refMod = HieRMod, fileName = hiermodFile)
      }else{
        HieRMod <- LoadHieRMod(fileName = hiermodFile)
        end_traintime <- Sys.time()
      }
      #Projection with HieRFIT
      start_testtime <- Sys.time()
      HierObj <- HieRFIT(Query = Data[as.vector(GenesOrder[c(1:NumGenes), i])+1, Test_Idx[[i]]], refMod = HieRMod)
      end_testtime <- Sys.time()
      gc()

    }else{
      start_traintime <- Sys.time()
      #Here Create HierMod:
      if(!file.exists(TreeTable)){
        treetable <- NULL
        threadN <- CreateDeNovoTree(Data[, Train_Idx[[i]]], Labels[Train_Idx[[i]]])$Nnode
        print("User tree is not found! Creating a tree from data...")
      }else{
        treetable <- read.delim(TreeTable, header=F)
        threadN <- CreateTree(treeTable=treetable)$Nnode
      }
      hiermodFile=paste(OutputDir, "/", i, "_HieRMod.Rdata.RDS", sep = "")
      if(!file.exists(hiermodFile)){
        HieRMod <- CreateHieR(RefData = Data[, Train_Idx[[i]]],
                              ClassLabels = Labels[Train_Idx[[i]]],
                              Tree = treetable,
                              thread = threadN,
                              species = "mmusculus")
        end_traintime <- Sys.time()
        SaveHieRMod(refMod = HieRMod, fileName = hiermodFile)
      }else{
        HieRMod <- LoadHieRMod(fileName = hiermodFile)
        end_traintime <- Sys.time()
      }
      #Projection with HieRFIT
      start_testtime <- Sys.time()
      HierObj <- HieRFIT(Query = Data[, Test_Idx[[i]]], refMod = HieRMod)
      end_testtime <- Sys.time()
    }

    Train_Time_HieRFIT[i] <- as.numeric(difftime(end_traintime,start_traintime,units = 'secs'))
    Test_Time_HieRFIT[i] <- as.numeric(difftime(end_testtime,start_testtime,units = 'secs'))
    True_Labels_HieRFIT[i] <- list(Labels[Test_Idx[[i]]])
    Pred_Labels_HieRFIT[i] <- list(as.vector(HierObj@Evaluation$Projection))

  }
  True_Labels_HieRFIT <- as.vector(unlist(True_Labels_HieRFIT))
  Pred_Labels_HieRFIT <- as.vector(unlist(Pred_Labels_HieRFIT))

  write.csv(True_Labels_HieRFIT,paste0(OutputDir,'/HieRFIT_true.csv'),row.names = FALSE)
  write.csv(Pred_Labels_HieRFIT,paste0(OutputDir,'/HieRFIT_pred.csv'),row.names = FALSE)
  write.csv(Train_Time_HieRFIT,paste0(OutputDir,'/HieRFIT_training_time.csv'),row.names = FALSE)
  write.csv(Test_Time_HieRFIT,paste0(OutputDir,'/HieRFIT_test_time.csv'),row.names = FALSE)

}

if (args[6] == "0") {
  run_HieRFIT(DataPath = args[1], LabelsPath = args[2], CV_RDataPath = args[3], OutputDir = args[4], TreeTable= args[7])
} else {
  run_HieRFIT(DataPath = args[1], LabelsPath = args[2], CV_RDataPath = args[3], OutputDir = args[4], GeneOrderPath = args[5], NumGenes = as.numeric(args[6]), TreeTable = args[7])
}
