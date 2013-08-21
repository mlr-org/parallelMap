#' Stops parallelization.
#'
#' The parallelMap mode is set to \dQuote{local}, i.e., parallelization is turned 
#' off. 
#' For snowfall \code{\link[snowfall]{sfStop}} is called.
#' 
#' After a subsequent call of \code{\link{parallelStart}}, no exported objects 
#' are present on the slaves and no libraries are loaded,
#' i.e., you have clean R sessions on the slaves. 
#'
#' @return Nothing.
#' @export
parallelStop = function() {
  status = getOption("parallelMap.status")
  
  # warn if we are not in started status
  if (status != "started") {
    warningf("parallelStop called, but parallelization was not started. Doing nothing.")
  } else {
    mode = getOption("parallelMap.mode")
    show.info = getOption("parallelMap.show.info")
    if (mode == "socket") {
      stopCluster(NULL)
      setDefaultCluster(NULL)      
    } else if (mode == "snowfall") {
      sfStop()
    } else if (mode == "BatchJobs") {
      # remove all exported libraries
      options(parallelMap.bj.packages=NULL)
      #FIXME remove?
      # clean up temp file dir of BJ
      #fd = getOption("parallelMap.bj.reg.file.path")
      #unlink(fd, recursive = TRUE)
    }
    if (show.info && mode != "local") {
      messagef("Stopped parallelization. All cleaned up.")
    }
  }
  
  # in any case be in local / stopped mode now 
  options(parallelMap.mode = "local")
  options(parallelMap.status = "stopped")
  invisible(NULL)
}
