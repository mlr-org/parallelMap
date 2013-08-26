#' Stops parallelization.
#'
#' The parallelMap mode is set to \dQuote{local}, i.e., parallelization is turned 
#' off. 
#'
#' After a subsequent call of \code{\link{parallelStart}}, no exported objects 
#' are present on the slaves and no libraries are loaded,
#' i.e., you have clean R sessions on the slaves. 
#' 
#' For socket and mpi mode \code{\link[parallel]{stopCluster}} is called.
#' 
#' For BatchJobs mode the subdirectory of the \code{storagedir}
#' containing the exported objects is removed.    
#'
#' @return Nothing.
#' @export
parallelStop = function() {
  # only do something if we are in "started" state
  if (isStatusStarted()) {
    if (isModeSocket() || isModeMPI()) {
      # only stop if we registred one (exception in parallelStart can happen)
      # otherwise we get error here. thanks to parallel we cannot even
      # ask for default cluster without exception
      # the whole following code is full of horrible stuff but I cannot change that
      cl = try(parallel:::defaultCluster(), silent=TRUE)
      if (!is.error(cl) && !is.null(cl)) {
        # great, another bug in parallel, stopCluster does not close socket connections
        # when you call it on the default cluster because of envir assign "magic"
        stopCluster(cl=cl)
        setDefaultCluster(NULL)
      }
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
