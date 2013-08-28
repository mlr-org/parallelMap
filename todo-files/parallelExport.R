#' Export a larger object which is needed in slave code of \code{\link{parallelMap}}.
#'
#' For local and multicore nothing is done, forking does not need extra exports.
#' 
#' For socket mode the objects are exported in a way loosely similar to \code{\link[parallel]{clusterExport}}, but without
#' the ugly and tedious environment setting. 
#' 
#' For BatchJobs the objects are stored on disk under the configured \code{storagedir}.
#' The subdirectory is called \dQuote{parallelMap_BatchJobs_exports} and 
#' automatically created during \code{\link{parallelStart}} and
#' removed during \code{\link{parallelStop}}.
#'
#' @param ... [\code{character(1)}]\cr
#'   Names of object to export.
#' @param objnames [\code{character(1)}]\cr
#'   Names of objects to export.
#'   Alternative way to pass arguments.
#' @return Nothing.
#' @export
#' @examples
#' foo <- 100
#' f <- function(x) x + foo
#' parallelStart(mode="local")
#' parallelExport("foo")
#' y <- parallelMap(f, 1:3)
#' parallelStop()
parallelExport = function(..., objnames) {
  args = list(...)
  checkListElementClass(args, "character")
  if (!missing(objnames)) {
    checkArg(objnames, "character", na.ok=FALSE)
    objnames = c(as.character(args), objnames)
  } else {
    objnames = as.character(args)
  }
  
  # do nothing if no exports 
  if (length(objnames) > 0) {
    if (isModeSocket() || isModeMPI()) {
      for (n in objnames) {
        exportToSlavePkgParallel(n, get(n, envir=sys.parent()))
      }
    } else if (isModeBatchJobs()) {
      bj.exports.dir = getBatchJobsExportsDir()
      for (n in objnames) {
        fn = file.path(bj.exports.dir, sprintf("%s.RData", n))
        save2(file = fn, get(n, envir=sys.parent()))
      }
    }
  }
  invisible(NULL)
}
