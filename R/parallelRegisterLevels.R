#' Register available parallelization levels in a client package.
#'
#' Call this in your\code{\link{.onLoad}} in your \dQuote{zzz.R}.
#'
#' @param package [\code{character(1)}]\cr
#'   Name of your package. Default is \code{NA} (no package, interactive use).
#' @param levels [\code{character(1)}]\cr
#'   Availabe levels that are used in the \code{\link{parallelMap}} operations of your package
#'   or code.
#'   If \code{package} is not missing, all levels will be prefixed with \dQuote{[package].}.
#' @return Nothing.
#' @export
parallelRegisterLevels = function(package = NA_character_, levels) {
  assertString(package, na.ok = TRUE)
  assertCharacter(levels, any.missing = FALSE)
  reg.levs = getPMOption("registered.levels", list())
  if (is.na(package)) {
    reg.levs[["<nopackage>"]] = union(reg.levs[["<nopackage>"]], levels)
  } else {
    reg.levs[[package]] = union(reg.levs[[package]], sprintf("%s.%s", package, levels))
  }
  reg.levs[[package]] = union(reg.levs[[package]], sprintf("%s.%s", package, levels))
  options(parallelMap.registered.levels = reg.levs)
  invisible(NULL)
}

#' Display registered parallelization levels for all currently loaded packages.
#'
#' @return Invisibly returns a list object that contains the displayed information.
#' @export
parallelShowRegisteredLevels = function() {
  reg.levs = getPMOption("registered.levels", list())
  if (length(reg.levs) == 0L) {
    message("No levels registered.")
  } else {
    reg.levs = reg.levs[order(names(reg.levs))]
    Map(function(pkg, lvls) {
      catf("%-20s: %s", pkg, collapse(lvls))
    }, pkg = names(reg.levs), lvls = reg.levs)
  }
  invisible(reg.levs)
}
