withCallingHandlers({
  install.packages('devtools', dependencies =T, repos="https://cloud.r-project.org/")
  install.packages('Seurat', dependencies =T, repos="https://cloud.r-project.org/")
},
warning = function(w) stop(w))
