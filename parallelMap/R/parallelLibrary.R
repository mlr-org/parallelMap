#' Load packages for parallelization.
#'
#' In case of snowfall mode, uses a combination of
#' \code{\link[snowfall]{sfClusterEval}} and \code{\link{require}}
#' to load the packages. For all other modes, the package is only
#' (potentially) loaded on the master.
#'
#' @param packages [\code{character}]\cr
#'   Names of packages to load.
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
parallelLibrary = function(packages, level=as.character(NA), master=TRUE) {
  checkArg(packages, "character", na.ok=FALSE)
  checkArg(level, "character", len=1L, na.ok=TRUE)
  checkArg(master, "logical", len=1L, na.ok=TRUE)
  
  mode = getOption("parallelMap.mode")
  
  # remove duplicates
  packages = unique(packages)
  
  # load packages on master
  if (master) {
    requirePackages(packages, why="parallelLibrary")
  }
  if (isParallelizationLevel(level)) {
    if (mode == "socket") {
      clusterCall(cl=NULL, assign, x=".parallelMap.pkgs", value=packages, pos=1)
      #clusterExport(cl=NULL, ".parallelMap.pkgs")
      clusterEvalQ(cl=NULL, for (p in .parallelMap.pkgs) {require(p, character.only=TRUE)})    
    } else if (mode == "snowfall") {
      # sfLibrary chatters to much...
      .parallelMap.pkgs = packages
      sfExport(".parallelMap.pkgs")
      sfClusterEval(for (p in .parallelMap.pkgs) {require(p, character.only=TRUE)})    
    } else if (mode == "BatchJobs") {
      # collect in R option
      oldpkgs = getOption("parallelMap.bj.packages", character(0))
      options(parallMap.bj.packages = union(oldpkgs, packages))
    }
  }
  invisible(NULL)
}

