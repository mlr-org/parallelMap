
getBatchJobsExportsDir = function() {
  file.path(getPMOptBatchJobsStorageDir(), ".parallelMap_BatchJobs_exports")
}

cleanUpBatchJobsExports = function() {
  bj.exports.dir = getBatchJobsExportsDir()
  fns = list.files(bj.exports.dir, full.names=TRUE)
  n = length(fns)
  if (length(fns) > 0L)  
    showInfoMessage("Deleting %i BatchJobs exports in: %s", n, bj.exports.dir)
  unlink(bj.exports.dir, recursive=TRUE)
}