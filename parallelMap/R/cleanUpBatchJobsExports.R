cleanUpBatchJobsExports = function() {
  bj.exports.dir = getBatchJobsExportsDir()
  fns = list.files(bj.exports.dir, full.names=TRUE)
  n = length(fns)
  if (length(fns) > 0L)  {
    showInfoMessage("Cleaning up %i BatchJobs export objects in dir:\n%s", n, bj.exports.dir)
    unlink(fns)
  }
}