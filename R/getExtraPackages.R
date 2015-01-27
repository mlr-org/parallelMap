getExtraPackages = function(mode) {
  if (mode %in% MODE_MPI)
    "Rmpi"
  else if (mode %in% MODE_BATCHJOBS)
    "BatchJobs"
  else
    character(0L)
}
