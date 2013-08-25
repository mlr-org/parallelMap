context("multicore mode")

# cran allows no multicore mode testing
#FIXME I also get strange messages in "make test" and interactive test, but
# apparently not when I really use the pkg...?
# .Warning in selectChildren(ac, 1) :
#  error 'Interrupted system call' in select
if (isExpensiveExampleOk()) {
  test_that("multicore mode", {
    parallelStartMulticore(2)
    partest1()
    parallelStop()
    
    expect_error(parallelStartMulticore(storagedir="xxx"))    
    
    parallelStartMulticore(2, logging=TRUE, storagedir=tempdir())
    partest2(tempdir())
    parallelStop()
    
    parallelStartMulticore(2)
    partest4(slave.error.test=FALSE)
    parallelStop()
  
    parallelStartMulticore(2)
    partest5()
    parallelStop()
  })
}