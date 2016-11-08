context("batchtools mode")

test_that("batchtools mode", {
  
  skip_if_not_installed("batchtools")

  library(batchtools)
  storagedir = tempdir()
  # if on lido  or SLURM for test, tempdir is not shared and test wih torque wont run
  if (makeRegistry(file.dir = NA)$cluster.functions$name %in% c("SLURM", "Torque")) {
    storagedir = getwd()
  }

  parallelStartBatchtools(storagedir = storagedir)
  partest1()
  parallelStop()

  # FIXME: Wait until https://github.com/hadley/testthat/issues/460 is fixed
  # parallelStartBatchtools(logging = TRUE, storagedir = storagedir)
  # partest2(storagedir)
  # parallelStop()

  parallelStartBatchtools(storagedir = storagedir)
  partest3()
  parallelStop()

  parallelStartBatchtools(storagedir = storagedir)
  # we cannot really check that wrong libraries are not loaded on slave here.
  # because we only load them during the job. but the error will show up then
  partest4(slave.error.test = FALSE)
  parallelStop()

  parallelStartBatchtools(storagedir = storagedir)
  partest5()
  parallelStop()

  parallelStartBatchtools(storagedir = storagedir)
  partest6(slave.error.test = FALSE)
  parallelStop()

  # test that expire generate exceptions
  # we can of course only do that on a true batch system
  if (makeRegistry(file.dir = NA)$cluster.functions$name %in% c("SLURM", "Torque")) {
    parallelStartBatchtools(storagedir = storagedir, bj.resources = list(walltime = 1))
    f = function(i) Sys.sleep(30 * 60)
    expect_error(suppressWarnings(parallelMap(f, 1:2)), "expired")
    parallelStop()
  }

  # test that working dir on master is working dir on slave
  oldwd = getwd()
  bn = "parallelMap_test_temp_dir_123"
  newwd = file.path(storagedir, bn)
  dir.create(newwd)
  setwd(newwd)
  parallelStartBatchtools(storagedir = storagedir)
  f = function(i) getwd()
  y = parallelMap(f, 1)
  parallelStop()
  expect_equal(basename(y[[1]]), bn)
  setwd(oldwd)
  unlink(newwd, recursive = TRUE)
})

