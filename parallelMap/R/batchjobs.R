getBatchJobsRegFileDir = function() {
  tempfile(pattern="parallelMap_BatchJobs_reg_", 
    tmpdir=getPMOptStorageDir())
}  

getBatchJobsExportsDir = function() {
  file.path(getPMOptStorageDir(), "parallelMap_BatchJobs_exports")
}

cleanUpBatchJobsExports = function() {
  bj.exports.dir = getBatchJobsExportsDir()
  fns = list.files(bj.exports.dir, full.names=TRUE)
  n = length(fns)
  if (n > 0L)  
    showInfoMessage("Deleting %i BatchJobs exports in: %s", n, bj.exports.dir)
  unlink(bj.exports.dir, recursive=TRUE)
}

optionBatchsJobsPackages = function(pkgs) {
  if (missing(pkgs))
    getOption("parallelMap.bj.packages", character(0))
  else
    options(parallelMap.bj.packages=pkgs)
}

# FIXME remove this after new version of bj on cran
getBJErrorMessages = function (reg, ids) {
  BatchJobs:::checkRegistry(reg)
  BatchJobs:::syncRegistry(reg)
  if (missing(ids)) 
    ids = BatchJobs:::dbFindErrors(reg)
  else ids = BatchJobs:::checkIds(reg, ids)
  tab = BatchJobs:::dbGetErrorMsgs(reg, ids, filter = FALSE)
  setNames(tab$error, tab$job_id)
}
