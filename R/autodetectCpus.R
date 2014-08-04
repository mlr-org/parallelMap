autodetectCpus = function(mode) {
  if (mode == MODE_MULTICORE) {
    cpus = parallel::detectCores()
  } else if (mode == MODE_MPI) {
    cpus = Rmpi::mpi.universe.size()
  } else {
    cpus = NA_integer_
  }
  if (!testCount(cpus, positive = TRUE))
    stopf("The was some problem in autodetecting the number of cpus. Autodetection returned:\n%s", printStrToChar(cpus))
  showInfoMessage("Autodetecting cpus: %i", cpus)
  return(cpus)
}
