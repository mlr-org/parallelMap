#' Stops parallelization.
#'
#' The parallelMap mode is set to \dQuote{local}, i.e., parallelization is turned 
#' off. 
#'
#' After a subsequent call of \code{\link{parallelStart}}, no exported objects 
#' are present on the slaves and no libraries are loaded,
#' i.e., you have clean R sessions on the slaves. 
#' 
#' For socket mode \code{\link[parallel]{stopCluster}} and  
#' \code{\link[parallel]{setDefaulCluster}} with argument \code{NULL} are called.
#' 
#' For mpi mode \code{\link[snowfall]{sfStop}} is called.
#'
#' For BatchJobs mode the subdirectory of the \code{storagedir}
#' containing the exported objects is removed.    
#'
#' @return Nothing.
#' @export
parallelStop = function() {
  # warn if we are not in started status
  if (isStatusStopped()) {
    warningf("parallelStop called, but parallelization was not started. Doing nothing.")
  } else {
    if (isModeSocket()) {
      stopCluster(NULL)
      setDefaultCluster(NULL)  
    } else if (isModeMPI()) {
      sfStop()
    } else if (isModeBatchJobs()) {
      # remove all exported libraries
      options(parallelMap.bj.packages=NULL)
      # remove exported objects
      cleanUpBatchJobsExports()
    } 
    if (!isModeLocal()) {
      showInfoMessage("Stopped parallelization. All cleaned up.")
    }
  }
  
  # in any case be in local / stopped mode now 
  options(parallelMap.mode = MODE_LOCAL)
  options(parallelMap.status = STATUS_STOPPED)
  invisible(NULL)
}
