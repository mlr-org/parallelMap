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
#' @param master [\code{logical(1)}]\cr
#'   Really export to package environment on master for local and multicore mode?
#'   If you do not do this your objects might not get exported for the mapping function call.
#'   Only disable when you are really sure.
#'   Default is \code{TRUE}.
#' @param show.info [\code{logical(1)}]\cr
#'   Verbose output on console?
#'   Can be used to override setting from options / \code{\link{parallelStart}}.
#'   Default is NA which means no overriding.
#' @return Nothing.
#' @export
parallelExport = function(..., objnames, master = TRUE, level = NA_character_, show.info = NA) {
  args = list(...)
  assertList(args, types = "character")
  if (!missing(objnames)) {
    assertCharacter(objnames, any.missing = FALSE)
    objnames = c(as.character(args), objnames)
  } else {
    objnames = as.character(args)
  }

  assertFlag(master)
  assertString(level, na.ok = TRUE)
  assertFlag(show.info, na.ok = TRUE)

  mode = getPMOptMode()

  # remove duplicates
  objnames = unique(objnames)

  if (length(objnames) > 0L) {
   if (isParallelizationLevel(level)) {
      if (master && (isModeLocal() || isModeMulticore())) {
        showInfoMessage("Exporting objects to package env on master for mode: %s",
          mode, collapse(objnames))
        for (n in objnames)
          # FIXME 2x envir!
          assign(n, get(n, envir = sys.parent()), envir = PKG_LOCAL_ENV)
      }
      if (isModeSocket() || isModeMPI()) {
        showInfoMessage("Exporting objects to slaves for mode %s: %s",
          mode, collapse(objnames))
        # export via our helper function
        for (n in objnames) {
          exportToSlavePkgParallel(n, get(n, envir = sys.parent()))
        }
      } else if (isModeBatchJobs()) {
        showInfoMessage("Storing objects in files for BatchJobs slave jobs: %s",
          collapse(objnames))
        objs = setNames(lapply(objnames, get, envir = sys.parent()), objnames)
        suppressMessages({
          BatchJobs::batchExport(getBatchJobsReg(), li = objs)
        })
      }
    }
  }
  invisible(NULL)
}
