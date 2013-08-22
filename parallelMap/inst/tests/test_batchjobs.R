context("BatchJobs mode")

if (isExpensiveExampleOk()) {
  test_that("BatchJobs mode", {
    parallelStart(mode="BatchJobs")
    partest1()
    parallelStop()
    
    parallelStart(mode="BatchJobs", log=tempdir())
    partest2(tempdir())
    parallelStop()
    
    parallelStart(mode="BatchJobs")
    partest3()
    parallelStop()
    
    parallelStart(mode="BatchJobs")
    partest4()
    parallelStop()
    
    # check error
    parallelStart(mode="BatchJobs", cpus=2)
    f = function(i) stop("fooo")
    expect_error(suppressWarnings(parallelMap(f, 1:3)), "fooo")
    parallelStop()    
    
  })
}  
