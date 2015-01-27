getBatchJobsNewRegFileDir = function() {
  fd = tempfile(pattern = "parallelMap_BatchJobs_reg_",
    tmpdir = getPMOptStorageDir())
  options(parallelMap.bj.reg.filedir = fd)
  return(fd)
}

getBatchJobsRegFileDir = function() {
  getOption("parallelMap.bj.reg.filedir")
}

getBatchJobsReg = function() {
  BatchJobs::loadRegistry(getBatchJobsRegFileDir())
}

