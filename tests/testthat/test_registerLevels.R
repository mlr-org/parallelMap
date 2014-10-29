context("register levels")

test_that("register levels", {
  parallelRegisterLevels("p1", "lev1")
  parallelRegisterLevels("p2", c("a", "b"))
  parallelRegisterLevels("p2", c("a", "b"))
  expect_output(
    parallelShowRegisteredLevels(),
    sprintf("%-20s: %s", "p1", "p1.lev1")
  )
  expect_output(
    parallelShowRegisteredLevels(),
    sprintf("%-20s: %s", "p2", "p2.a,p2.b")
  )
  parallelRegisterLevels(levels = c("x", "y"))
  expect_output(
    parallelShowRegisteredLevels(),
    sprintf("%-20s: %s", "<nopackage>", "x,y")
  )
})
