#' @title Retrieve the configured package options.
#'
#' @description
#' Returned are current and default settings, both as lists.
#' The return value has slots elements \code{settings} and \code{defaults},
#' which are both lists of the same structure, named by option names.
#'
#' A printer exists to display this object.
#'
#' For details on the configuration procedure please read
#' \code{\link{parallelStart}} and \url{https://github.com/berndbischl/parallelMap}.
#'
#' @return [\code{ParallelMapOptions}]. See above.
#' @export
parallelGetOptions = function() {
  opts = c("mode", "cpus", "level", "logging", "show.info", "storagedir", "bj.resources")
  settings = setNames(lapply(opts, getPMOption), opts)
  defaults = setNames(lapply(opts, getPMDefOption), opts)
  makeS3Obj("ParallelMapOptions", settings = settings, defaults = defaults)
}

#' @export
print.ParallelMapOptions = function(x, ...) {
  mycat = function(opt) {
    opt1val = opts$settings[[opt]]
    opt2val = opts$defaults[[opt]]
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
  opts = parallelGetOptions()
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

