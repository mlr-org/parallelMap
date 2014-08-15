#' @title Stops parallelization.
#'
#' @description
#' Sets mode to \dQuote{local}, i.e., parallelization is turned
#' off and all necessary stuff is cleaned up.
#'
#' For socket and mpi mode \code{\link[parallel]{stopCluster}} is called.
#'
#' For BatchJobs mode the subdirectory of the \code{storagedir}
#' containing the exported objects is removed.
#'
#' After a subsequent call of \code{\link{parallelStart}}, no exported objects
#' are present on the slaves and no libraries are loaded,
#' i.e., you have clean R sessions on the slaves.
#'
#' @return Nothing.
#' @export
parallelStop = function() {
  # only do something if we are in "started" state
  if (isStatusStarted()) {
    if (isModeSocket() || isModeMPI()) {
      # only stop if we registred one (exception in parallelStart can happen)
      # the whole following code is full of horrible stuff but I cannot change that
      # parallel is really buggy and the design is horrible
      # a) stopCluster will not work when called via stopCluster(NULL) on the default cluster
      #    Through some envir assign "magic" cl gets set to NULL before it is stopped
      #    via S3 inheritance
      # b) stopCluster will also throw amn exception when none is registered. great, and apparently
      #    we have no way of asking whether one is alrealdy registered.
      cl = get("default", envir = getFromNamespace(".reg", ns = "parallel"))
      if (!is.null(cl)) {
        stopCluster(cl = cl)
        setDefaultCluster(NULL)
      }
    } else if (isModeBatchJobs()) {
      # delete registry file dir
      unlink(getBatchJobsRegFileDir(), recursive = TRUE)
    }
    if (!isModeLocal()) {
      showInfoMessage("Stopped parallelization. All cleaned up.")
    }
  }

  # remove our local export collection (local + multicore mode)
  rm(list = ls(PKG_LOCAL_ENV), envir = PKG_LOCAL_ENV)

  # in any case be in local / stopped mode now
  options(parallelMap.mode = MODE_LOCAL)
  options(parallelMap.status = STATUS_STOPPED)

  # FIXME do we clean up log files?

  invisible(NULL)
}
