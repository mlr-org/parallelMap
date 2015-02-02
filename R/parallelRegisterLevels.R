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
#' \code{parallelRegisterLevels(package="foo", levels="dummy")}
#' will register the level \dQuote{foo.dummy} and users can start parallelization for this level with
#' \code{parallelStart(<backend>, level = "parallelMap.dummy")}.
#' If you do not provide \code{package}, the level names will be associated with category
#' \dQuote{custom} and can there be later refered to with \dQuote{custom.dummy}.
#'
#' @param package [\code{character(1)}]\cr
#'   Name of your package.
#'   Default is \dQuote{custom} (we are not in a package).
#' @param levels [\code{character(1)}]\cr
#'   Availabe levels that are used in the \code{\link{parallelMap}} operations of your package
#'   or code.
#'   If \code{package} is not missing, all levels will be prefixed with \dQuote{[package].}.
#' @return Nothing.
#' @export
parallelRegisterLevels = function(package = "custom", levels) {
  assertString(package)
  assertCharacter(levels, min.len = 1L, any.missing = FALSE)
  reg.levs = getPMOption("registered.levels", list())
  if (is.na(package)) {
    reg.levs[["custom"]] = union(reg.levs[["custom"]], levels)
  } else {
    reg.levs[[package]] = union(reg.levs[[package]], sprintf("%s.%s", package, levels))
  }
  options(parallelMap.registered.levels = reg.levs)
  invisible(NULL)
}

#' @title Get registered parallelization levels for all currently loaded packages.
#'
#' @description
#' The S3 object only has one slot, which is called \code{levels}.
#' This contains a named list. Each name refers to \code{package} from the call to
#' \code{\link{parallelRegisterLevels}}, while the entries are character
#' vectors of the form \dQuote{package.level}.
#' @return [code{RegisteredLevels}]. See above.
#' @export
parallelGetRegisteredLevels = function() {
  lvls = getPMOption("registered.levels", list())
  makeS3Obj("RegisteredLevels", levels = lvls)
}

#' @export
print.RegisteredLevels = function(x, ...) {
  levs = parallelGetRegisteredLevels()$levels
  ns = names(levs)
  for (i in seq_along(levs)) {
    catf("%s: %s", ns[i], collapse(levs[[i]], sep = ", "))
  }
  invisible(NULL)
}

