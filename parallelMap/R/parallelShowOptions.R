#' @export
parallelShowOptions = function() {
  mycat = function( opt) {
    opt1val = getPMOption(opt)
    opt2val = getPMDefOption(opt)
    if (is.null(opt2val))
      opt2val = "not set"
    catf("%-20s: %-10s (%s)", opt, opt1val, opt2val)
  }
  catf("%-20s: %-10s (%s)", "parallelMap options", "value", "default")
  catf("")
  mycat("mode")
  mycat("cpus")
  mycat("level")
  mycat("logdir")
  mycat("autostart")
  mycat("show.info")
}

#FIXME define NULL as autodected for cpus