parallelShowOptions = function() {
  mycat = function( opt) {
    opt1 = sprintf("parallelMap.%s", opt)
    opt1val = getOption(opt1)
    opt2 = sprintf("parallelMap.default.%s", opt)
    opt2val = getOption(opt2)
    if (is.null(opt2val))
      opt2val = "not set"
    catf("%-20s: %-10s (%s)", opt, opt1val, opt2val)
  }
  catf("%-20s: %-10s (%s)", "parallelMap options", "value", "default")
  mycat("mode")
  mycat("cpus")
  mycat("level")
  mycat("log")
 
}