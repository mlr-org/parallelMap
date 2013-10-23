context("BatchJobs mode")

test_that("BatchJobs mode", {
  
  storagedir = tempdir()
  # if on lido for test, tempdir is not shared and test wih torque wont run
  if (Sys.info()["nodename"] %in% c("lidong1", "lidong2")) {
    storagedir = getwd()
  }

  parallelStartBatchJobs(storagedir=storagedir)
  partest1()
  parallelStop()
  
  parallelStartBatchJobs(logging=TRUE, storagedir=storagedir)
  partest2(storagedir)
  parallelStop()
  
#   parallelStartBatchJobs(storagedir=storagedir)
#   partest3()
#   parallelStop()
  
  parallelStartBatchJobs(storagedir=storagedir)
  # we cannot really check that wromg libraries are not loaded on slave here.
  # because we only load them duzring the job. but the error will show up then
  partest4(slave.error.test=FALSE)
  parallelStop()
  
  parallelStartBatchJobs(storagedir=storagedir)
  partest5()
  parallelStop()    
})
  
