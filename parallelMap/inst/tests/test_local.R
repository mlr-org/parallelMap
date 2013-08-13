context("local mode")

test_that("local mode", {
  parallelStart(mode="local")
  parallelStart(mode="local", cpus=1)
  expect_error(parallelStart(mode="local", cpus=2))
  parallelStart(mode="local", level="foo")
  expect_error(parallelStart(mode="local", log=tempdir()))
  partest1()
  partest3()
  parallelStop()
})