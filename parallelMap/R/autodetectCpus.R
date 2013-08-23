autodetectCpus = function(mode) {
  cpus = 
    if (isModeLocal()) {
      NA_integer_
    } else if (isModeMulticore()) {
      parallel::detectCores()
    } else if (isModeSocket()) {
      warningf("Autodetecting cpus was not possible for mode %s, setting cpus to 1.", mode)
      1L
    } else if (isModeMPI()) {
      Rmpi::mpi.universe.size()
    } else if (isModeBatchJobs()) {
      NA_integer_
    }
  if (!is.na(cpus))
    showInfoMessage("Autodetecting cpus: %i", cpus)
  return(cpus)
}