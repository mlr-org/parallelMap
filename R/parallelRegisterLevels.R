#' @title Register a parallelization level
#'
#' @description
#' Package developers should call this function in their packages' \code{\link[base]{.onLoad}}.
#' This enables the user to query available levels and bind parallelization to specific levels.
#' This is especially helpful in case of nested calls to \code{\link{parallelMap}}, i.e. where
#' the inner call should be parallelized instead of the outer one.
#'
#' To avoid name clases, we encourage developes to always sepecify the argument \code{package}.
#' This will prefix the specified levels with the string containing the package name, e.g.
#' \code{parallelRegisterLevels("parallelMap", "dummy")} will register the level \dQuote{parallelMap.dummy}
#' and users can start parallelization for this level with
#' \code{parallelStart(<backend>, level = "parallelMap.dummy")}.
#' If you do not provide \code{package}, the level names will be taken as-is and sorted in will be put
#' into the category \dQuote{interactive} by \code{\link{parallelGetRegisteredLevels}}.
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
    reg.levs[["interactive"]] = union(reg.levs[["interactive"]], levels)
  } else {
    reg.levs[[package]] = union(reg.levs[[package]], sprintf("%s.%s", package, levels))
  }
  options(parallelMap.registered.levels = reg.levs)
  invisible(NULL)
}

#' Get registered parallelization levels for all currently loaded packages.
#'
#' @return Returns a named list with all registered levels.
#' @export
parallelGetRegisteredLevels = function() {
  reg.levs = getPMOption("registered.levels", list())
  reg.levs[order(names(reg.levs))]
}
