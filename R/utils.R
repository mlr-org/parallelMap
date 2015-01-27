# show message if OPTION show.info is TRUE
#  show.info ARGUMENT provides an immediate OVERRIDE to that option
showInfoMessage = function(msg, ..., show.info=NA) {
  if (ifelse(is.na(show.info), getPMOptShowInfo(), show.info))
    messagef(msg, ...)
}

showStartupMsg = function(mode, cpus, socket.hosts) {
  if (mode != MODE_LOCAL) {
    if (mode %in% c(MODE_MULTICORE, MODE_MPI) ||
      (mode == MODE_SOCKET && !is.na(cpus))) {
      showInfoMessage("Starting parallelization in mode=%s with cpus=%i.",
        mode, cpus)
    } else if (mode == MODE_SOCKET) {
      showInfoMessage("Starting parallelization in mode=%s on %i hosts.",
        mode, length(socket.hosts))
    } else if (mode == MODE_BATCHJOBS) {
      showInfoMessage("Starting parallelization in mode=%s-%s.",
        mode, BatchJobs::getConfig()$cluster.functions$name)
    }
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
