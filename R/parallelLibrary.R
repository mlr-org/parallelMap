#' @title Load packages for parallelization.
#'
#' @description
#' Makes sure that the packages are loaded so that they can be used in a job
#' function which is later run with \code{\link{parallelMap}}.
#'
#' For all modes, the packages are also (potentially) loaded on the master.
#'
#' @param ... [\code{character(1)}]\cr
#'   Names of packages to load.
#' @param packages [\code{character(1)}]\cr
#'   Names of packages to load.
#'   Alternative way to pass arguments.
#' @param master [\code{logical(1)}]\cr
#'   Load packages also on master?
#'   Default is \code{TRUE}.
#' @param level [\code{character(1)}]\cr
#'   If a (non-missing) level is specified in \code{\link{parallelStart}},
#'   the function only loads the packages if the level specified here matches.
#'   See \code{\link{parallelMap}}.
#'   Useful if this function is used in a package.
#'   Default is \code{NA}.
#' @return Nothing.
#' @export
parallelLibrary = function(..., packages, master=TRUE, level=as.character(NA)) {
  args = list(...)
  checkListElementClass(args, "character")
  if (!missing(packages)) {
    checkArg(packages, "character", na.ok=FALSE)
    packages = c(as.character(args), packages)
  } else {
    packages = as.character(args)
  }
  checkArg(level, "character", len=1L, na.ok=TRUE)
  checkArg(master, "logical", len=1L, na.ok=TRUE)

  mode = getPMOptMode()

  # remove duplicates
  packages = unique(packages)

  if (length(packages) > 0L) {
    # load packages on master, for local and multicore we have to do this as well
    if (master || mode %in% c(MODE_LOCAL, MODE_MULTICORE)) {
      requirePackages(packages, why="parallelLibrary")
    }

    # if level matches, load on slaves
    if (isParallelizationLevel(level)) {
      if (mode %in% c(MODE_SOCKET, MODE_MPI)) {
        showInfoMessage("Loading packages on slaves: %s", collapse(packages))
        .parallelMap.pkgs = packages
        exportToSlavePkgParallel(".parallelMap.pkgs", .parallelMap.pkgs)
        # oks is a list (slaves) of logical vectors (pkgs)
        oks = clusterEvalQ(cl=NULL, {
          sapply(.parallelMap.pkgs, require, character.only=TRUE, USE.NAMES=TRUE)
        })
        # get not loaded pkgs
        not.loaded = lapply(oks, function(v) {
          names(v)[!v]
        })
        not.loaded = unique(unlist(not.loaded))
        if (length(not.loaded) > 0L)
          stopf("Packages could not be loaded on all slaves: %s.", collapse(not.loaded))
      } else if (isModeBatchJobs()) {
        showInfoMessage("Storing package info for BatchJobs slave jobs: %s", collapse(packages))
        # collect in R option, add new packages to old ones
        optionBatchsJobsPackages(union(optionBatchsJobsPackages(), packages))
      }
    }
  }
  invisible(NULL)
}

