context("snowfall mode")

if (isExpensiveExampleOk()) {
  test_that("snowfall mode", {
    parallelStart(mode="snowfall", cpus=2)
    partest1()
    parallelStop()

    parallelStart(mode="snowfall", cpus=2, type="MPI")
    partest1()
    parallelStop()
    
    parallelStart(mode="snowfall", cpus=2, log=tempdir())
    partest2(tempdir())
    parallelStop()
    
    parallelStart(mode="snowfall", cpus=2)
    partest3()
    parallelStop()

    # check error
    parallelStart(mode="snowfall", cpus=2)
    f = function(i) stop("fooo")
    expect_error(suppressWarnings(parallelMap(f, 1:3)), "fooo")
    parallelStop()    
    
  })
}  
