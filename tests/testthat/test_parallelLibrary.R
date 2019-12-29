context("parallelLibrary")

# issue https://github.com/mlr-org/parallelMap/issues/67
test_that("exported packages honor the given parallelization level", {

  # for some reasons travis is missing package 'rpart' when loading even
  # though its available
  skip_on_ci()

  parallelRegisterLevels(levels = "test")
  parallelStartSocket(1, level = "custom.test")
  parallelLibrary(packages = "rpart")

  out = parallelMap(function(.) search(), 1, level = "custom.test")[[1]]
  parallelStop()

  expect_true(any(grepl("package:rpart", out)))
})
