context("batchtools mode")

test_that("batchtools mode", {
  requireNamespace("batchtools")
  reg = batchtools::makeRegistry(NA)
  storagedir = reg$temp.dir
  if (is.null(storagedir) || is.na(storagedir)) {
    storagedir = tempfile()
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
  if (batchtools::makeRegistry(file.dir = NA)$cluster.functions$name %in% c("SLURM", "Torque")) {
    parallelStartBatchtools(storagedir = storagedir, bj.resources = list(walltime = 5))
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

test_that("batchtools error imputation", {
  skip_on_cran()
  requireNamespace("batchtools")
  reg = batchtools::makeRegistry(NA)
  storagedir = reg$temp.dir
  if (is.null(storagedir) || is.na(storagedir)) {
    storagedir = tempfile()
  }

  oldBSP = Sys.getenv("R_BATCHTOOLS_SEARCH_PATH")
  Sys.setenv(R_BATCHTOOLS_SEARCH_PATH = storagedir)

  cat("cluster.functions = makeClusterFunctionsSSH(list(Worker$new('localhost', ncpus = 2)))",
    file = file.path(storagedir, "batchtools.conf.R")
  )

  partestUnalive(
    parallelStartBatchtools(storagedir = storagedir),
    parallelStop()
  )

  if (nzchar(oldBSP)) Sys.setenv(R_BATCHTOOLS_SEARCH_PATH = oldBSP)
})
