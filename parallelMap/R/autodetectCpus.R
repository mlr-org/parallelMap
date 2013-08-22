autodetectCpus = function(mode) {
  switch(mode,
    MODE_MULTICORE = parallel::detectCores(),
    MODE_MPI = Rmpi::mpi.universe.size(),
    1L     
  )
}