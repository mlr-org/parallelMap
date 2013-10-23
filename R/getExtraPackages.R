getExtraPackages = function(mode) {
  packs = 
    if (mode %in% c(MODE_MULTICORE, MODE_SOCKET))
      "parallel"
    else if (isModeMPI())
      c("Rmpi", "parallel")
    else if (isModeBatchJobs())
      "BatchJobs"
}