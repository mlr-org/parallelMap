library(methods)
library(devtools)
library(testthat)
library(BBmisc)
options(BBmisc.ProgressBar.style = "off")

if (interactive()) {
  load_all(".", reset=TRUE)
} else {
  library(parallelMap)
}
source("inst/tests/helpers.R")
source("inst/tests/sockettest.R")
test_dir("inst/tests")

