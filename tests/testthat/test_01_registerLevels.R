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
  expect_equal(parallelGetRegisteredLevels(flatten = TRUE), c("p1.lev1", "p2.a", "p2.b"))
  parallelRegisterLevels(levels = c("x", "y"))
  expect_equal(
    parallelGetRegisteredLevels()$levels,
    list(p1 = "p1.lev1", p2 = c("p2.a", "p2.b"), custom = c("custom.x", "custom.y"))
  )
  expect_equal(parallelGetRegisteredLevels(flatten = TRUE),
    c("p1.lev1", "p2.a", "p2.b", "custom.x", "custom.y"))
})

test_that("warn on unregisterred level", {
  # check that we warn
  expect_warning(parallelStartBatchJobs(level = "foo"), "not registered")
  parallelStop()

  # check that we DONT warn for no level
  opt = getOption("warn")
  options(warn = 2L)
  parallelStartBatchJobs()
  parallelStop()
  options(warn = opt)
})
