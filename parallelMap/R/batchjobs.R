getBatchJobsRegFileDir = function() {
  tempfile(pattern="parallelMap_BatchJobs_reg_", 
    tmpdir=getPMOptBatchJobsStorageDir())
}  

getBatchJobsExportsDir = function() {
  file.path(getPMOptBatchJobsStorageDir(), "parallelMap_BatchJobs_exports")
}

cleanUpBatchJobsExports = function() {
  bj.exports.dir = getBatchJobsExportsDir()
  fns = list.files(bj.exports.dir, full.names=TRUE)
  n = length(fns)
  if (length(fns) > 0L)  
    showInfoMessage("Deleting %i BatchJobs exports in: %s", n, bj.exports.dir)
  unlink(bj.exports.dir, recursive=TRUE)
}

optionBatchsJobsPackages = function(pkgs) {
  if (missing(pkgs))
    getOption("parallelMap.bj.packages", character(0))
  else
    options(parallelMap.bj.packages=pkgs)
}