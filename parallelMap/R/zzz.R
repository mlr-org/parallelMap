#' @import BBmisc

.onLoad = function(libname, pkgname) {
  options(parallelMap.mode = getOption("parallelMap.mode", "local"))
  options(parallelMap.cpus = getOption("parallelMap.cpus", 1L))
  options(parallelMap.level = getOption("parallelMap.level",  as.character(NA)))
  options(parallelMap.log = getOption("parallelMap.log", as.character(NA)))
}
