context("mpi mode")

#FIXME: for some reason this blocks R CMD check, at least on my laptop?
if (interactive()) {
  test_that("mpi mode", {
    parallelStart(mode="mpi", cpus=2)
    partest1()
    parallelStop()

    parallelStart(mode="mpi", cpus=2, type="MPI")
    partest1()
    parallelStop()
    
    parallelStart(mode="mpi", cpus=2, logging=TRUE, storage=tempdir())
    partest2(tempdir())
    parallelStop()
    
    parallelStart(mode="mpi", cpus=2)
    partest3()
    parallelStop()

    parallelStart(mode="mpi", cpus=2)
    partest4(slave.error.test=TRUE)
    parallelStop()
    
    parallelStart(mode="mpi", cpus=2)
    partest5()
    parallelStop()
  })
}  
