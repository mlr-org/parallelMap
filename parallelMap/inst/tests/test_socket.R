context("socket mode")

#FIXME: for some reason this blocks R CMD check, at least on my laptop?
test_that("socket mode", {
  parallelStart(mode="socket", cpus=2)
  partest1()
  parallelStop()

  parallelStart(mode="socket", cpus=2,  logging=TRUE, storagedir=tempdir())
  partest2(tempdir())
  parallelStop()
  
  parallelStart(mode="socket", cpus=2)
  partest3()
  parallelStop()

  parallelStart(mode="socket", cpus=2)
  partest4()
  parallelStop()
  
  # check error
  parallelStart(mode="socket", cpus=2)
  f = function(i) stop("fooo")
  expect_error(suppressWarnings(parallelMap(f, 1:3)), "fooo")
  parallelStop()    
})
