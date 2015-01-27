#' @title Load packages for parallelization.
#'
#' @description
#' Makes sure that the packages are loaded in slave process so that they can be used in a job
#' function which is later run with \code{\link{parallelMap}}.
#'
#' For all modes, the packages are also (potentially) loaded on the master.
#'
#' @param ... [\code{character}]\cr
#'   Names of packages to load.
#' @param packages [\code{character(1)}]\cr
#'   Names of packages to load.
#'   Alternative way to pass arguments.
#' @param master [\code{logical(1)}]\cr
#'   Load packages also on master for any mode?
#'   Default is \code{TRUE}.
#' @param level [\code{character(1)}]\cr
#'   If a (non-missing) level is specified in \code{\link{parallelStart}},
#'   the function only loads the packages if the level specified here matches.
#'   See \code{\link{parallelMap}}.
#'   Useful if this function is used in a package.
#'   Default is \code{NA}.
#' @param show.info [\code{logical(1)}]\cr
#'   Verbose output on console?
#'   Can be used to override setting from options / \code{\link{parallelStart}}.
#'   Default is NA which means no overriding.
#' @return Nothing.
#' @export
parallelLibrary = function(..., packages, master = TRUE, level = NA_character_, show.info = NA) {
  args = list(...)
  assertList(args, types = "character")
  if (!missing(packages)) {
    assertCharacter(packages, any.missing = FALSE)
    packages = c(as.character(args), packages)
  } else {
    packages = as.character(args)
  }
  assertFlag(master)
  assertString(level, na.ok = TRUE)
  assertFlag(show.info, na.ok = TRUE)

  mode = getPMOptMode()

  # remove duplicates
  packages = unique(packages)

  if (length(packages) > 0L) {
    if (master) {
      requirePackages(packages, why = "parallelLibrary")
    }

    # if level matches, load on slaves
    if (isParallelizationLevel(level)) {
      # only load when we have not already done on master
      if (mode %in% c(MODE_LOCAL)) {
        if (master) {
          showInfoMessage("Packages already available on the slaves")
        } else {
          showInfoMessage("Loading packages on master (to be available on slaves for mode %s): %s",
            mode, collapse(packages), show.info = show.info)
        requirePackages(packages, why = "parallelLibrary")
        }
      } else if (mode %in% c(MODE_SOCKET, MODE_MPI)) {
        showInfoMessage("Loading packages on slaves for mode %s: %s",
          mode, collapse(packages), show.info = show.info)
        .parallelMap.pkgs = packages
        exportToSlavePkgParallel(".parallelMap.pkgs", .parallelMap.pkgs)
        # oks is a list (slaves) of logical vectors (pkgs)
        oks = clusterEvalQ(cl = NULL, {
          vapply(.parallelMap.pkgs, require, character.only = TRUE, USE.NAMES = TRUE, FUN.VALUE = NA)
        })
        # get not loaded pkgs
        not.loaded = lapply(oks, function(v) {
          names(v)[!v]
        })
        not.loaded = unique(unlist(not.loaded))
        if (length(not.loaded) > 0L)
          stopf("Packages could not be loaded on all slaves: %s.", collapse(not.loaded))
      } else if (mode %in% c(MODE_BATCHJOBS)) {
        showInfoMessage("Storing package info for BatchJobs slave jobs: %s",
          collapse(packages), show.info = show.info)
        # collect in R option, add new packages to old ones
        suppressMessages({
          reg = getBatchJobsReg()
          BatchJobs::addRegistryPackages(reg, packages)
        })
      }
    }
  }
  invisible(NULL)
}
