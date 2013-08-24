getExtraPackages = function(mode) {
  packs = 
    if (isModeMulticore() || isModeSocket())
      "parallel"
    else if (isModeMPI())
      c("snowfall", "Rmpi")
    else if (isModeBatchJobs())
      "BatchJobs"
}