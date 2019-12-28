withCallingHandlers({
  install.packages("BiocManager", repos="https://cloud.r-project.org/")
  BiocManager::install(c("S4Vectors", "hopach", "limma"))
  install.packages("devtools", repos="https://cloud.r-project.org/")
  devtools::install_github("SydneyBioX/scClassify")
},
warning = function(w) stop(w))
