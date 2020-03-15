context("reproducibility")

test_that("reproducibility with standard RNG kind works for 'socket' mode", {
  set.seed(42)
  parallelStartSocket(cpus = 2)
  foo1 <- parallelMap(runif, rep(3, 2))
  parallelStop()

  set.seed(42)
  parallelStartSocket(cpus = 2)
  foo2 <- parallelMap(runif, rep(3, 2))
  parallelStop()

  expect_equal(foo1, foo2)
})

test_that("socket: reproducibility can be turned off", {
  set.seed(42)
  parallelStartSocket(cpus = 2, reproducible = FALSE)
  foo1 <- parallelMap(runif, rep(3, 2))
  parallelStop()

  set.seed(42)
  parallelStartSocket(cpus = 2, reproducible = FALSE)
  foo2 <- parallelMap(runif, rep(3, 2))
  parallelStop()

  # would be class "logical" if TRUE
  expect_is(all.equal(foo1, foo2), "character")
})

test_that("reproducibility with standard RNG kind works for 'multicore' mode", {
  skip_on_os("windows")

  set.seed(42)
  parallelStartMulticore(2)
  foo3 = parallelMap(rnorm, 1:2)
  parallelStop()

  set.seed(42)
  parallelStartMulticore(2)
  foo4 = parallelMap(rnorm, 1:2)
  parallelStop()

  expect_equal(foo3, foo4)
})

# This is how it was before v1.5 -> set.seed() with standard RNG kind had no
# effect
test_that("multicore: reproducibility with standard RNG kind can be turned off", {
  skip_on_os("windows")

  set.seed(42)
  parallelStartMulticore(2, reproducible = FALSE)
  foo3 = parallelMap(rnorm, 1:2)
  parallelStop()

  set.seed(42)
  parallelStartMulticore(2, reproducible = FALSE)
  foo4 = parallelMap(rnorm, 1:2)
  parallelStop()

  # would be class "logical" if TRUE
  expect_is(all.equal(foo3, foo4), "character")
})

test_that("reproducibility with L'Ecuyer-CMRG RNG kind works for 'multicore' mode", {
  skip_on_os("windows")

  # NB: this RNG kind should always work, even without reproducible = TRUE
  set.seed(42, "L'Ecuyer-CMRG")
  parallelStartMulticore(2)
  foo5 = parallelMap(rnorm, 1:2)
  parallelStop()

  set.seed(42, "L'Ecuyer-CMRG")
  parallelStartMulticore(2)
  foo6 = parallelMap(rnorm, 1:2)
  parallelStop()

  expect_equal(foo5, foo6)
})

# I do not think we can do anything here:
# 1. This RNG kind always forces reproducibility in parallel processes,
# even when mc.set.seed = FALSE is FALSE
test_that("reproducibility with L'Ecuyer-CMRG RNG kind works even when 'reproducible = FALSE'", {
  skip_on_os("windows")

  # NB: this RNG kind should always work, even without reproducible = TRUE
  set.seed(42, "L'Ecuyer-CMRG")
  parallelStartMulticore(2, reproducible = FALSE)
  foo5 = parallelMap(rnorm, 1:2)
  parallelStop()

  set.seed(42, "L'Ecuyer-CMRG")
  parallelStartMulticore(2, reproducible = FALSE)
  foo6 = parallelMap(rnorm, 1:2)
  parallelStop()

  expect_equal(foo5, foo6)
})
