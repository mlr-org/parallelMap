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
source("tests/testthat/helpers.R")
source("tests/testthat/helper_sockettest.R")
test_dir("tests/testthat")

