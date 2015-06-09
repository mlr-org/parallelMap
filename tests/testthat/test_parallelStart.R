context("parallelStart")

#FIXME: I do NOT know why this blocks in R CMD check
if (interactive()) {

test_that("parallelStart finds regged level", {
  oldopt = getOption("warn")
  options(warn = 2L)
  parallelRegisterLevels(levels = "bla")
  parallelStartSocket(level = "custom.bla", cpus = 2L)
  parallelStop()
  # remove regged level again for clean state
  options(parallelMap.registered.levels = list())
  options(warn = oldopt)
})

}
