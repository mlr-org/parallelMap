isParallelizationLevel = function(level) {
  optlevel = getOption("parallelMap.level")
  is.na(optlevel) || is.na(level) || level != optlevel
}
