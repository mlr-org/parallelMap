#' A parallel verions of apply-family functions
#'
#' \code{parallelLapply}: A parallel \code{\link{lapply}} version.
#' \code{parallelSapply}: A parallel \code{\link{sapply}} version.
#' 
#' All functions are simple wrappers for \code{\link{parallelMap}}
#'
#' @param xs [\code{vector} | \code{list}]\cr
#'   \code{fun} is applied to the the elements of this argument.
#' @param fun [\code{function}]\cr
#'   Function to map over \code{xs}.
#' @param ... [any]\cr
#'   Further arguments passed to \code{fun}.
#' @param simplify [\code{logical(1)}]\cr
#'   See \code{\link{sapply}}.
#'   Default is \code{TRUE}.
#' @param use.names [\code{logical(1)}]\cr
#'   See \code{\link{sapply}}.
#'   Default is \code{TRUE}.
#' @param level [\code{character(1)}]\cr
#'   See \code{\link{parallelMap}}.
#' @return For \code{parallelLapply} an unamed list, 
#'   \code{parallelSapply} it depends on \code{fun} and the set arguments.
#' @export
parallelLapply = function(xs, fun, ..., level=NA_character_) {
  more.args = list(...)
  parallelMap(fun, xs, more.args=more.args, level=level, simplify=FALSE, use.names=FALSE)
}

#' @rdname parallelLapply
#' @export
parallelSapply = function(xs, fun, ..., simplify=TRUE, use.names=TRUE, level=NA_character_) {
  more.args = list(...)
  parallelMap(fun, xs, more.args=more.args, simplify=simplify, use.names=use.names, level=level)
}
