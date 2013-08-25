
context("socket mode")

# cran allows socket mode with 2 localhost processes
if (interactive()) {
  test_that("socket mode", {
    sockettest()
  })
}
