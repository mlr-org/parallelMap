#' Displays the configured package options.
#' 
#' Displayed are current and default settings. 
#' 
#' For details on the configuration procedure please read 
#FIXME url. 
#' \code{\link{parallelStart}} and \url{github}.
#' 
#' @export
parallelShowOptions = function() {
  mycat = function(opt) {
    opt1val = getPMOption(opt)
    opt2val = getPMDefOption(opt)
    if (is.null(opt2val))
      opt2val = "not set"
    if (opt != "storagedir")
      catf("%-20s: %-10s (%s)", opt, opt1val, opt2val)
    else
      catf("%-20s: %-10s\n                     (%s)", opt, opt1val, opt2val)
  }
  catf("%-20s: %-10s (%s)", "parallelMap options", "value", "default")
  catf("")
  mycat("autostart")
  mycat("mode")
  mycat("cpus")
  mycat("level")
  mycat("logging")
  mycat("show.info")
  mycat("storagedir")
}

#FIXME define NULL as autodected for cpus