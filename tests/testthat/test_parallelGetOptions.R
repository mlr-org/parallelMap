context("get / print options")

test_that("get / print options", {
  opts = parallelGetOptions()
  expect_true(is.list(opts))
  expect_equal(names(opts), c("settings", "defaults"))
  expect_equal(names(opts$settings), names(opts$defaults))

  capture.output(
    print(parallelGetOptions())
  )
})
