getExtraPackages = function(mode) {
  print(mode)
  x = switch(mode, 
    MODE_MULTICORE = "parallel",
    MODE_MPI = c("snowfall", "Rmpi"),
    MODE_BATCHJOBS = "BatchJobs",
    character(0)
  )  
  print(x)
  x
}