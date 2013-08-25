library(methods)
library(devtools)
library(testthat)
library(BBmisc)
options(BBmisc.ProgressBar.style = "off")

if (interactive()) {
  load_all("parallelMap", reset=TRUE)
} else {
  library(parallelMap)  
}
source("parallelMap/inst/tests/helpers.R")
source("parallelMap/inst/tests/sockettest.R")
test_dir("parallelMap/inst/tests")

