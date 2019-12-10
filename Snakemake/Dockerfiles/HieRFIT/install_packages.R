withCallingHandlers({
  install.packages(c("devtools", "caret", "data.tree"), dependencies =T, repos="https://cloud.r-project.org/")
},
warning = function(w) stop(w))
