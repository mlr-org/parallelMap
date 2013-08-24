#' Register available parallelization levels in a client package.
#'
#' Call this in your\code{\link{.onLoad}} in your \dQuote{zzz.R}.
#'
#' @param package [\code{character(1)}]\cr
#'   Name of your package.
#' @param levels [\code{character(1)}]\cr
#'   Availabe levels that used in your \code{\link{parallelMap}} operations in your package.
#' @return Nothing.
#' @export
registerLevels = function(package, levels) {
  checkArg(package, "character", len=1L, na.ok=FALSE)
  checkArg(levels, "character", na.ok=FALSE)
  reg.levs = getPMOption("registered.levels", list())
  reg.levs[[package]] = levels
  options(parallelMap.registered.levels = reg.levs)
  invisible(NULL)
}

#' Display registered parallelization levels for all currently loaded packages.
#'
#' @return Invisibly returns a list object that contains the displayed information.
#' @export
showRegisteredLevels = function() {
  reg.levs = getPMOption("registered.levels")
  for (i in seq_along(reg.levs)) {
    p = names(reg.levs)[[i]]
    levs = reg.levs[[i]]
    catf("%-20s: %s", p, collapse(levs))
  }
  invisible(reg.levs)
}  
