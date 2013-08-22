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
parallelExport = function(ns, values=NULL) {
  checkArg(ns, "character", na.ok=FALSE)
  #FIXMEe cehck length of values
  envir = sys.parent()
  #args = argsAsNamedList(...)
  #checkListElementClass(args, "character")
  #checkArg(obj.names, "character", na.ok=FALSE)
  #ns = union(unlist(args), obj.names)
  #FIXME do socket
  switch( getPMOptMode(), 
    MODE_SNOWFALL = {
      # FIXME really test this with multiople function levels
      sfExport(list=ns)
    },
    MODE_BATCHJOBS = {
      bj.exports.dir = getBatchJobsExportsDir()
      for (n in ns) {
        fn = file.path(bj.exports.dir, sprintf("%s.RData", n))
        #FIXME repair get
        save2(file = fn, get(n, envir=sys.parent()))
      }
    }
  )
  invisible(NULL)
}

