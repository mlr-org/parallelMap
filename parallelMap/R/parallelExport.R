#' Export a larger object which is needed in slave code of \code{\link{parallelMap}}.
#'
#' For local and multicore mode the objects are stored in a package environment,
#' for snowfall \code{\link[snowfall]{sfExport}} is used internally.
#'
#' @param ... [\code{character(1)}]\cr
#'   Names of object to export.
#' @param obj.names [\code{character(1)}]\cr
#'   Names of objects to export.
#'   Alternative way to pass arguments.
#' @return Nothing.
#' @export
#' @examples
#' foo <- 100
#' f <- function(x) x + foo
#' parallelStart(mode="local")
#' parallelExport("foo")
#' y <- parallelMap(f, 1:3)
#' parallelStop()
parallelExport = function(..., obj.names=character(0)) {
  args = list(...)
  checkListElementClass(args, "character")
  checkArg(obj.names, "character", na.ok=FALSE)
  ns = union(unlist(args), obj.names)
  mode = getOption("parallelMap.mode")
  
  #FIXME do socket
  if (mode == "snowfall") {
    # FIXME really test this with multiople function levels
    sfExport(list=ns)
  } else if (mode == "BatchJobs") {
    fd = getOption("parallelMap.bj.reg.file.path")
    for (n in ns) {
      save2(file = file.path(fd, n), get(n, envir=sys.parent()))
    }
  }
  invisible(NULL)
}

