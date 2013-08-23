getExtraPackages = function(mode) {
  packs = 
    if (isModeMulticore())
      "parallel"
    else if (isModeMPI())
      c("snowfall", "Rmpi")
    else if (isModeBatchJobs())
      "BatchJobs"
}