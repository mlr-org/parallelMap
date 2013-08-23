isShowInfoEnabled = function() {
  getPMOptShowInfo()
}

showInfoMessage = function(msg, ...) {
  if (isShowInfoEnabled()) {
    messagef(msg, ...)
  }
}

getBatchJobsExportsDir = function() {
   bj.exports.dir = "parallelMap_BatchJobs_exports"    
}

cleanUpBatchJobsExports = function() {
  bj.exports.dir = getBatchJobsExportsDir()
  fns = list.files(bj.exports.dir, full.names=TRUE)
  n = length(fns)
  if (length(fns) > 0L)  {
    showInfoMessage("Cleaning up %i BatchJobs export objects in dir:\n%s", n, bj.exports.dir)
    unlink(fns)
  }
}

isParallelizationLevel = function(level) {
  optlevel = getOption("parallelMap.level")
  is.na(optlevel) || is.na(level) || level != optlevel
}
