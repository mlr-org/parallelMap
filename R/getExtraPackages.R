getExtraPackages = function(mode) {
  if (mode %in% MODE_MPI)
    c("Rmpi", "parallel")
  else if (mode %in% MODE_BATCHJOBS)
    "BatchJobs"
  else
    character(0L)
}
