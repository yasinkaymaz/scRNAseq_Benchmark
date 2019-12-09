withCallingHandlers({
  install.packages("devtools", repos="https://cloud.r-project.org/")
  devtools::install_github("yasinkaymaz/HieRFIT")
},
warning = function(w) stop(w))
