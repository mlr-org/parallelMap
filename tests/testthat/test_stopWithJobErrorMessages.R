
context("stopWithJobErrorMessages")

test_that("stopWithJobErrorMessages", {
  inds = seq_along(letters)
  msgs = letters
  expect_error(stopWithJobErrorMessages(inds, msgs),
    sprintf("Errors occurred in %i slave jobs", length(letters)))
})


