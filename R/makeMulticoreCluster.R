# fake cluster constructor mimicking makeCluster to store some settings.
makeMulticoreCluster = function(mc.preschedule = FALSE, mc.set.seed = TRUE, mc.silent = FALSE, mc.cleanup = TRUE) {
  assertFlag(mc.preschedule)
  assertFlag(mc.set.seed)
  assertFlag(mc.silent)
  assertFlag(mc.cleanup)

  x = get(".MulticoreCluster", envir = getNamespace("parallelMap"))
  x$mc.preschedule = mc.preschedule
  x$mc.set.seed = mc.set.seed
  x$mc.silent = mc.silent
  x$mc.cleanup = mc.cleanup
  invisible(TRUE)
}

MulticoreClusterMap = function(FUN, ...) {
  opts = as.list(get(".MulticoreCluster", envir = getNamespace("parallelMap")))
  mcmapply_fixed(FUN, ...,
    mc.preschedule = opts$mc.preschedule,
    mc.set.seed = opts$mc.set.seed,
    mc.silent = opts$mc.silent,
    mc.cleanup = opts$mc.cleanup)
}
