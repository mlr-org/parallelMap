 library(testthat)
 library(BBmisc)

test_package("parallelMap")

#FIXME: bad hack 
# for some reason using test_package and opening a socked node
# blocks R CMD check
# but we really want to test at least one real parallel mode on cran 
 
if (!interactive()) {
  library(parallelMap)
  source(system.file("tests/helpers.R", package="parallelMap"))
  source(system.file("tests/sockettest.R", package="parallelMap"))
  sockettest() 
}
