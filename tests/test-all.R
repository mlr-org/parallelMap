library(testthat)
test_check("parallelMap")

#FIXME: bad hack 
# for some reason using test_package and opening a socked node
# blocks R CMD check
# but we really want to test at least one real parallel mode on cran 
 
if (!interactive()) {
  source(system.file("tests/helpers.R", package="parallelMap"))
  source(system.file("tests/helper_sockettest.R", package="parallelMap"))
  sockettest() 
}
