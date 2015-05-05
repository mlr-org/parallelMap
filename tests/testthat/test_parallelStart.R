context("parallelStart")

test_that("parallelStart finds regged level", {
  oldopt = getOption("warn")
  options(warn = 2L)
  parallelRegisterLevels(levels = "bla")
  parallelStartSocket(level = "custom.bla", cpus = 2L)
  parallelStop()
  options(warn = oldopt)
})


