context("multicore mode")

test_that("multicore mode", {
  parallelStart(mode="multicore", cpus=2)
  partest1()
  parallelStop()
  
  expect_error(parallelStart(mode="multicore", log="xxx"))    
  
  parallelStart(mode="multicore", log=tempdir())
  partest2(tempdir())
  parallelStop()
  
  parallelStart(mode="multicore", log=tempdir())
  partest4()
  parallelStop()
  
  # check error
  # FIXME this does not work as parallel/multicore only generates a 
  # warning not an error....
  #parallelStart(mode="multicore", cpus=2)
  #f = function(i) stop("fooo")
  #expect_error(suppressWarnings(parallelMap(f, 1:3)), "fooo")
  #parallelStop()    
})
