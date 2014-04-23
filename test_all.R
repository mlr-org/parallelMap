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
# but onyl do this on non-batch systems
# on the batch systems we test in full parallel mode
conf = BatchJobs:::getBatchJobsConf()
if (conf$cluster.functions$name == "Interactive")
  conf$cluster.functions = makeClusterFunctionsLocal()
test_dir("tests/testthat", filter = "bat")

