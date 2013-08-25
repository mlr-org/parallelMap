context("mpi mode")

#FIXME: for some reason this blocks R CMD check, at least on my laptop?
# cran allows no mpi mode testing
if (interactive()) {
  test_that("mpi mode", {
    parallelStartMPI(2)
    partest1()
    parallelStop()

    parallelStartMPI(2)
    partest1()
    parallelStop()
    
    parallelStartMPI(2, logging=TRUE, storage=tempdir())
    partest2(tempdir())
    parallelStop()
    
    parallelStartMPI(2)
    partest3()
    parallelStop()

    parallelStartMPI(2)
    partest4(slave.error.test=TRUE)
    parallelStop()
    
    parallelStartMPI(2)
    partest5()
    parallelStop()
  })
}  
