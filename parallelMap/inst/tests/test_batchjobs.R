context("BatchJobs mode")

test_that("BatchJobs mode", {
  parallelStartBatchJobs(storagedir=tempdir())
  partest1()
  parallelStop()
  
  parallelStartBatchJobs(logging=TRUE, storagedir=tempdir())
  partest2(tempdir())
  parallelStop()
  
  parallelStartBatchJobs(storagedir=tempdir())
  partest3()
  parallelStop()
  
  parallelStartBatchJobs(storagedir=tempdir())
  # we cannot really check that wromg libraries are not loaded on slave here.
  # because we only load them duzring the job. but the error will show up then
  partest4(slave.error.test=FALSE)
  parallelStop()
  
  parallelStartBatchJobs(storagedir=tempdir())
  partest5()
  parallelStop()    
})
  
