args <- commandArgs(TRUE)
suppressPackageStartupMessages(library(tidyverse,quietly = T))
suppressPackageStartupMessages(library(HieRFIT,quietly = T))

CalculateComplexity <- function(DataPath, LabelsPath, col_Index){
  col_Index <- as.numeric(col_Index)
  RefData <- read.csv(DataPath, row.names = 1)
  RefData = t(as.matrix(RefData))
  exp <- apply(RefData, 2, function(x) (x/sum(x))*10000)
  RefData <- log1p(exp)

  ClassLabels <- as.matrix(read.csv(LabelsPath))
  ClassLabels <- as.vector(ClassLabels[, col_Index])
  ClassLabels <- FixLab(xstring = ClassLabels)
  refData_mean <- NULL
  for(ct in names(table(ClassLabels) > 10)){
    dt <- RefData[, ClassLabels == ct]
    ctmean <- rowMeans(as.matrix(dt))
    refData_mean <- cbind(refData_mean, ctmean)
  }
  colnames(refData_mean) <- names(table(ClassLabels) > 10)
  df <- cor(refData_mean) %>% reshape2::melt() %>% filter(Var1 != Var2) %>% group_by(Var2) %>% summarise(Cmax=max(value)) %>% as.data.frame()
  #return(mean(df$Cmax))
  return(mean(head(sort(df$Cmax,decreasing = T), n = (length(df$Cmax)+1)/4)))
}

cat(CalculateComplexity(DataPath = args[1], LabelsPath = args[2], col_Index=args[3]), sep = "\n")
