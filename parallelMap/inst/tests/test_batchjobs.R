context("BatchJobs mode")

if (isExpensiveExampleOk()) {
  test_that("BatchJobs mode", {
    parallelStart(mode="BatchJobs", storagedir=tempdir())
    partest1()
    parallelStop()
    
    parallelStart(mode="BatchJobs", logging=TRUE, storagedir=tempdir())
    partest2(tempdir())
    parallelStop()
    
    parallelStart(mode="BatchJobs", storagedir=tempdir())
    partest3()
    parallelStop()
    
    parallelStart(mode="BatchJobs", storagedir=tempdir())
    #FIXME we cannot really check that wromg libraries are not loaded on slave here.
    # because we only load them duzring the job. but the error will show up then
    partest4(slave.error.test=FALSE)
    parallelStop()
    
    parallelStart(mode="BatchJobs", storagedir=tempdir())
    partest5()
    parallelStop()    
  })
}  
