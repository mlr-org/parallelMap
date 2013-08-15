#' @import BBmisc

.onLoad = function(libname, pkgname) {
  options(parallelMap.mode = "local")
  options(parallelMap.cpus = 1L)
  options(parallelMap.level = as.character(NA))
  options(parallelMap.log = NULL) 
}
