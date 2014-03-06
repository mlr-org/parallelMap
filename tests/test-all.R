library(testthat)
test_check("parallelMap")

#FIXME: bad hack
# for some reason using test_package and opening a socked node
# blocks R CMD check
# but we really want to test at least one real parallel mode on cran

if (!interactive()) {
  library(BBmisc)
  library(parallelMap)
  source("testthat/helpers.R")
  source("testthat/helper_sockettest.R")
  sockettest()
}
