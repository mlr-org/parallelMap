# check dir exists and is indeed a dir
checkDir = function(dirname, dir) {
  if (!file.exists(dir))
    stopf("%s directory does not exists: %s", dirname, dir)
  if (!isDirectory(dir))
    stopf("% directory is not a directory: %s", dirname, dir)
}

isShowInfoEnabled = function() {
  getPMOptShowInfo()
}

# show message if show.info is TRUE
showInfoMessage = function(msg, ...) {
  if (isShowInfoEnabled()) {
    messagef(msg, ...)
  }
}

# either the option level is not set or it is and the level of parmap matches
isParallelizationLevel = function(level) {
  optlevel = getPMOptLevel()
  is.na(optlevel) || (!is.na(level) && level == optlevel)
}

exportToSlavePkgParallel = function(objname, objval) {
  # clusterExport is trash because of envir argument, we cannot easily export
  # stuff defined in the scope of an R function
  # cl = NULL is default cluster, pos=1 is always globalenv
  # I really hope the nextline does what I think in all cases...
  clusterCall(cl=NULL, assign, x=objname, value=objval, pos=1)
}

