context("parallel apply")

test_that("parallelLapply", {
  parallelStart(mode="local")

  ys = parallelLapply(1:2, identity)
  expect_equal(ys, as.list(1:2))
  
  parallelStop()
})


test_that("parallelSapply", {
  parallelStart(mode="local")

  ys = parallelSapply(1:2, identity, use.names=FALSE)
  expect_equal(ys, 1:2)
  ys = parallelSapply(1:2, identity, use.names=TRUE)
  expect_equal(ys, setNames(1:2, 1:2))
  
  parallelStop()
})
