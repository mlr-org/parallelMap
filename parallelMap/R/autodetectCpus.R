autodetectCpus = function(mode) {
  print(mode)
  cpus = 
    if (isModeMulticore()) {
      parallel::detectCores()
    } else if (isModeMPI()) {
      Rmpi::mpi.universe.size()
    }
  if (!(is.integer(cpus) && length(cpus) == 1L && !is.na(cpus)))
    stopf("The was some problem in autodetecting the number of cpus. Autodetection returned:\n%s",
      printStrToChar(cpus))
  showInfoMessage("Autodetecting cpus: %i", cpus)
  return(cpus)
}