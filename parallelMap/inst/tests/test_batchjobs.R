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
    partest4()
    parallelStop()
    
    # check error
    #FIXME generalize these
    parallelStart(mode="BatchJobs", storagedir=tempdir())
    f = function(i) stop("fooo")
    expect_error(suppressWarnings(parallelMap(f, 1:3)), "fooo")
    parallelStop()    
    
  })
}  
