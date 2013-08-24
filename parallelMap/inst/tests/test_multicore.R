context("multicore mode")

test_that("multicore mode", {
  parallelStartMulticore(2)
  partest1()
  parallelStop()
  
  expect_error(parallelStartMulticore(storagedir="xxx"))    
  
  parallelStartMulticore(2, logging=TRUE, storagedir=tempdir())
  partest2(tempdir())
  parallelStop()
  
  parallelStartMulticore(2)
  partest4(slave.error.test=FALSE)
  parallelStop()

  parallelStartMulticore(2)
  partest5()
  parallelStop()
})
