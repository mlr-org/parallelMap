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

# issue https://github.com/mlr-org/parallelMap/issues/41
test_that("parallelGetOptions() prints the state of the object", {
  parallelStartSocket(2)
  y = parallelGetOptions()
  parallelStop()

  expect_match(
    capture.output(print(y))[3],
    "mode                : socket     \\(not set\\)"
  )
})
