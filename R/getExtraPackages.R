getExtraPackages = function(mode) {
  switch(mode,
    MODE_MPI = "Rmpi",
    MODE_BATCHJOBS = "BatchJobs",
    MODE_BATCHTOOLS = "batchtools",
    character(0L)
  )
}
