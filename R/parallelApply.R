#' Parallel versions of apply-family functions.
#'
#' `parallelLapply`: A parallel [lapply()] version.\cr
#' `parallelSapply`: A parallel [sapply()] version.\cr
#' All functions are simple wrappers for [parallelMap()].
#'
#' @param xs (`vector` | `list`)\cr
#'   `fun` is applied to the elements of this argument.
#' @param fun [`function`]\cr
#'   Function to map over `xs`.
#' @param ... (any)\cr
#'   Further arguments passed to `fun`.
#' @param simplify (`logical(1)`)\cr
#'   See [sapply()].
#'   Default is `TRUE`.
#' @param use.names (`logical(1)`)\cr
#'   See [sapply()].
#'   Default is `TRUE`.
#' @param impute.error (`NULL` | `function(x)`)\cr
#'   See [parallelMap()].
#' @param level (`character(1)`)\cr
#'   See [parallelMap()].
#' @return For `parallelLapply` an unamed list, for `parallelSapply` it depends
#'   on the return value of `fun` and the settings of `simplify` and
#'   `use.names`.
#' @export
parallelLapply = function(xs, fun, ..., impute.error = NULL, level = NA_character_) {
  parallelMap(fun, xs, more.args = list(...), simplify = FALSE, use.names = FALSE,
    impute.error = impute.error, level = level)
}

#' @rdname parallelLapply
#' @export
parallelSapply = function(xs, fun, ..., simplify = TRUE, use.names = TRUE, impute.error = NULL,
  level = NA_character_) {
  parallelMap(fun, xs, more.args = list(...), simplify = simplify, use.names = use.names,
    impute.error = impute.error, level = level)
}
