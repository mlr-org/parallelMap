#' @import BBmisc

.onLoad = function(libname, pkgname) {
  # init all settings from defaults
  options(parallelMap.mode = getOption("parallelMap.default.mode", "local"))
  options(parallelMap.cpus = getOption("parallelMap.default.cpus", 1L))
  options(parallelMap.level = getOption("parallelMap.default.level",  as.character(NA)))
  options(parallelMap.log = getOption("parallelMap.default.log", as.character(NA)))
  options(parallelMap.autostart = getOption("parallelMap.default.autostart", TRUE))
  options(parallelMap.show.info = getOption("parallelMap.default.show.info", TRUE))
  options(parallelMap.status = "stopped")
}
