context("register levels")

test_that("register levels", {
  registerLevels("p1", "lev1")
  registerLevels("p2", c("a", "b"))
  expect_output(
    showRegisteredLevels(),
    sprintf("%-20s: %s", "p1", "lev1")
  ) 
  expect_output(
    showRegisteredLevels(),
    sprintf("%-20s: %s", "p2", "a,b")
  )
})