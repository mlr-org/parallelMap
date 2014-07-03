#' Displays the configured package options.
#'
#' Displayed are current and default settings.
#'
#' For details on the configuration procedure please read
#' \code{\link{parallelStart}} and \url{https://github.com/berndbischl/parallelMap}.
#'
#' @export
parallelShowOptions = function() {
  mycat = function(opt) {
    opt1val = getPMOption(opt)
    opt2val = getPMDefOption(opt)
    if (opt == "bj.resources") {
      opt1val = ifelse(length(opt1val) == 0L, "(defaults from BatchJobs config)",
        convertToShortString(opt1val))
      if (!is.null(opt2val))
        opt2val = convertToShortString(opt2val)
    }
    if (is.null(opt2val))
      opt2val = "not set"
    if (opt %nin% c("bj.resources", "storagedir"))
      catf("%-20s: %-10s (%s)", opt, opt1val, opt2val)
    else
      catf("%-20s: %-10s\n                      (%s)", opt, opt1val, opt2val)
  }
  catf("%-20s: %-10s (%s)", "parallelMap options", "value", "default")
  catf("")
  mycat("mode")
  mycat("cpus")
  mycat("level")
  mycat("logging")
  mycat("show.info")
  mycat("storagedir")
  if (isModeBatchJobs() || identical(getPMDefOptMode(), MODE_BATCHJOBS))
    mycat("bj.resources")
}
