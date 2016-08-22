context("multicore mode")

# cran allows no multicore mode testing
#FIXME: I also get strange messages in "make test" and interactive test, but
# apparently not when I really use the pkg...?
# .Warning in selectChildren(ac, 1) :
#  error 'Interrupted system call' in select
if (isExpensiveExampleOk()) {
  test_that("multicore mode", {
    parallelStartMulticore(2)
    partest1()
    parallelStop()

    parallelStartMulticore(2, load.balancing = TRUE)
    partest1()
    parallelStop()

    expect_error(parallelStartMulticore(storagedir = "xxx"))

    parallelStartMulticore(2, logging = TRUE, storagedir = tempdir())
    # FIXME: see issue #33
    partest2(tempdir(), test.warning = FALSE)
    parallelStop()

    parallelStartMulticore(2, mc.preschedule = FALSE)
    partest4(slave.error.test = FALSE)
    parallelStop()

    parallelStartMulticore(2)
    partest5()
    parallelStop()

    parallelStartMulticore(2)
    partest6(slave.error.test = FALSE)
    parallelStop()

    parallelStartMulticore(2, load.balancing = TRUE)
    partest7()
    parallelStop()

  })
}
