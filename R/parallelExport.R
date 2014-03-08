#' @title Export R objects for parallelization.
#'
#' @description
#' Makes sure that the objects are exported to slave process so that they can be used in a job
#' function which is later run with \code{\link{parallelMap}}.
#'
#' @param ... [\code{character}]\cr
#'   Names of objects to export.
#' @param objnames [\code{character(1)}]\cr
#'   Names of objects to export.
#'   Alternative way to pass arguments.
#' @param level [\code{character(1)}]\cr
#'   If a (non-missing) level is specified in \code{\link{parallelStart}},
#'   the function only exports if the level specified here matches.
#'   See \code{\link{parallelMap}}.
#'   Useful if this function is used in a package.
#'   Default is \code{NA}.
#' @return Nothing.
#' @export
parallelExport = function(..., objnames, level=as.character(NA)) {
  args = list(...)
  checkListElementClass(args, "character")
  if (!missing(objnames)) {
    checkArg(objnames, "character", na.ok=FALSE)
    objnames = c(as.character(args), objnames)
  } else {
    objnames = as.character(args)
  }

  mode = getPMOptMode()

  # remove duplicates
  objnames = unique(objnames)

  if (length(objnames) > 0) {
    if (isParallelizationLevel(level)) {
      showInfoMessage("Exporting to slaves: %s", collapse(objnames))
      if (isModeSocket() || isModeMPI()) {
        # export via our helper function
        for (n in objnames) {
          exportToSlavePkgParallel(n, get(n, envir=sys.parent()))
        }
      } else if (isModeBatchJobs()) {
        # export via fail::put, make sure names are correctly set
        bj.exports.dir = getBatchJobsExportsDir()
        fail.handle = fail::fail(bj.exports.dir)
        objs = setNames(lapply(objnames, get, envir=sys.parent()), objnames)
        fail.handle$put(li=objs)
      }
    }
  }
  invisible(NULL)
}



