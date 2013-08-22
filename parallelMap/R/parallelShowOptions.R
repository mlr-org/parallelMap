parallelShowOptions = function() {
  mycat = function( opt) {
    opt1val = getPMOpt(opt)
    opt2val = getPMDefOpt(opt)
    if (is.null(opt2val))
      opt2val = "not set"
    catf("%-20s: %-10s (%s)", opt, opt1val, opt2val)
  }
  catf("%-20s: %-10s (%s)", "parallelMap options", "value", "default")
  mycat("mode")
  mycat("cpus")
  mycat("level")
  mycat("log")
  mycat("autostart")
  mycat("show.info")
}