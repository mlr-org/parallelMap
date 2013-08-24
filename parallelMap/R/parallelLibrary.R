#' Load packages for parallelization.
#'
#' Makes sure that case of socket, mpi and BatchJobs mode, 
#' the package is loaded in the slave processes.
#' For all modes the package also (potentially) loaded on the master.
#' Note that loading the package on the master is (obviously) required for
#' having it available in the slave operation for modes local and multicore.
#'
#' @param ... [\code{character(1)}]\cr
#'   Names of packages to load.
#' @param packages [\code{character(1)}]\cr
#'   Names of packages to load.
#'   Alternative way to pass arguments.
#' @param level [\code{character(1)}]\cr
#'   The function only loads the packages if the same level is specified in
#'   \code{\link{parallelStart}} or this argument is \code{NA}.
#'   See \code{\link{parallelMap}}. 
#'   Default is \code{NA}.
#' @param master [\code{logical(1)}]\cr
#'   Load packages also on master?       
#'   If you set this to \code{FALSE}, nothing actually
#'   happens for modes local and multicore.
#'   Default is \code{TRUE}.
#' @return Nothing.
#' @export
parallelLibrary = function(..., packages, level=as.character(NA), master=TRUE) {
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
    # load packages on master
    if (master) {
      requirePackages(packages, why="parallelLibrary")
    }
  
    if (isParallelizationLevel(level)) {
      messagef("Loading packages on slaves: %s", collapse(packages))
      if (mode %in% c(MODE_SOCKET, MODE_MPI)) {
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
        # collect in R option, add new packages to old ones
        optionBatchsJobsPackages(union(optionBatchsJobsPackages(), packages))      
      }
    }
  }
  invisible(NULL)
}

