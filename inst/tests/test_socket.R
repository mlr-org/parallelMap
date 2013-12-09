
context("socket mode")

# cran allows socket mode with 2 localhost processes
test_that("socket mode", {
  sockettest()
})
