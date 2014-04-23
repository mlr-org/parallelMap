library(methods)
library(devtools)
library(testthat)
library(BBmisc)
library(BatchJobs)
options(BBmisc.ProgressBar.style = "off")

if (interactive()) {
  load_all(".", reset = TRUE)
} else {
  library(parallelMap)
}
source("tests/testthat/helpers.R")
source("tests/testthat/helper_sockettest.R")

# make sure to run in external R process so we can check exports
conf = BatchJobs:::getBatchJobsConf()
conf$cluster.functions = makeClusterFunctionsLocal()
test_dir("tests/testthat")

