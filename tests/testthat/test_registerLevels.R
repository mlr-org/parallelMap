context("register levels")

test_that("register levels", {
  parallelRegisterLevels("p1", "lev1")
  parallelRegisterLevels("p2", c("a", "b"))
  parallelRegisterLevels("p2", c("a", "b"))
  expect_equal(
    parallelGetRegisteredLevels(),
    list(p1 = "p1.lev1", p2 = c("p2.a", "p2.b"))
  )
  parallelRegisterLevels(levels = c("x", "y"))
  expect_equal(
    parallelGetRegisteredLevels(),
    list("interactive" = c("x", "y"), p1 = "p1.lev1", p2 = c("p2.a", "p2.b"))
  )
})
