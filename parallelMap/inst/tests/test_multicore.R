context("multicore mode")

test_that("multicore mode", {
  parallelStart(mode="multicore", cpus=2)
  partest1()
  parallelStop()
  
  expect_error(parallelStart(mode="multicore", storagedir="xxx"))    
  
  parallelStart(mode="multicore", logging=TRUE, storagedir=tempdir())
  partest2(tempdir())
  parallelStop()
  
  parallelStart(mode="multicore")
  partest4()
  parallelStop()

  parallelStart(mode="multicore")
  partest5()
  parallelStop()
})
