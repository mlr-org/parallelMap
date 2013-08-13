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
test_dir("parallelMap/inst/tests")

