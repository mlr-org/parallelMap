context("BatchJobs mode")

test_that("BatchJobs mode", {
  k = autodetectCpus(MODE_MULTICORE)
  expect_true(is.integer(k) && length(k) == 1L)
})
