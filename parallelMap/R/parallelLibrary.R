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
  # load packages on master
  if (master) {
    requirePackages(packages, why="parallelLibrary")
  }
  if (getOption("BBmisc.parallel.mode") == "snowfall" && 
        (is.na(getOption("BBmisc.parallel.level")) || 
           getOption("BBmisc.parallel.level") == level)) {
    # sfLibrary chatters to much...
    .BBmisc.snowfall.pkgs = packages; sfExport(".BBmisc.snowfall.pkgs")
    sfClusterEval(for (p in .BBmisc.snowfall.pkgs) {require(p, character.only=TRUE)})    
  }
  invisible(NULL)
}

