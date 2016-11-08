getBatchtoolsNewRegFileDir = function() {
  fd = tempfile(pattern = "parallelMap_batchtools_reg_",
    tmpdir = getPMOptStorageDir())
  options(parallelMap.bt.reg.filedir = fd)
  return(fd)
}

getBatchtoolsRegFileDir = function() {
  getOption("parallelMap.bt.reg.filedir")
}

getBatchtoolsReg = function() {
  batchtools::loadRegistry(file.dir = getBatchtoolsRegFileDir())
}

