context("register levels")

test_that("register levels", {
  expect_equal(parallelGetRegisteredLevels()$levels, list())
  parallelRegisterLevels("p1", "lev1")
  parallelRegisterLevels("p2", c("a", "b"))
  parallelRegisterLevels("p2", c("a", "b"))
  expect_equal(
    parallelGetRegisteredLevels()$levels,
    list(p1 = "p1.lev1", p2 = c("p2.a", "p2.b"))
  )
  parallelRegisterLevels(levels = c("x", "y"))
  expect_equal(
    parallelGetRegisteredLevels()$levels,
    list(p1 = "p1.lev1", p2 = c("p2.a", "p2.b"), custom = c("custom.x", "custom.y"))
  )
})
