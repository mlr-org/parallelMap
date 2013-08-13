#' Export a larger object which is needed in slave code of \code{\link{parallelMap}}.
#'
#' Objects can later be retrieved with \code{\link{parallelGetExported}} in slave code.
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
#' f <- function(x) x + parallelGetExported("foo")
#' parallelStart(mode="local")
#' parallelExport("foo")
#' y <- parallelMap(f, 1:3)
#' parallelStop()
parallelExport = function(..., obj.names=character(0)) {
  args = list(...)
  checkListElementClass(args, "character")
  checkArg(obj.names, "character", na.ok=FALSE)
  ns = union(unlist(args), obj.names)
  mode = getOption("BBmisc.parallel.mode")
  
  if (mode %in% c("local", "multicore")) {
    # multicore does not require to export because mem is duplicated after fork (still copy-on-write)
    #options(BBmisc.parallel.export.env = ".BBmisc.parallel.export.env")
    #for (n in ns) {
    #  assign(n, get(n, envir=sys.parent()), envir=.BBmisc.parallel.export.env)
    #}
  }  else if (mode == "snowfall") {
    sfExport(list=ns)
    #sfClusterEval(options(BBmisc.parallel.export.env = ".GlobalEnv"))
  } else if (mode == "BatchJobs") {
    fd = getOption("BBmisc.parallel.bj.reg.file.path")
    for (n in ns) {
      save2(file = file.path(fd, n), get(n, envir=sys.parent()))
    }
  }
  invisible(NULL)
}

# #' Retrieve a with \code{\link{parallelExport}} exported in slave code.
# #'
# #' @param name [\code{character(1)}]\cr
# #'   Name of exported object.
# #' @return [any]. Object value.
# #' @export
# parallelGetExported = function(name) {
#   penv = getOption("BBmisc.parallel.export.env")
#   if (penv == ".BBmisc.parallel.export.env")
#     get(name, envir=.BBmisc.parallel.export.env)
#   else
#     get(name, envir=.GlobalEnv)
# }
# 

# parallelExport = function(...) {
#  mode = getOption("BBmisc.parallel.mode")
#   # multicore does not require to export because mem is duplicated after fork (still copy-on-write)
# 	if (mode == "snowfall") {
#    args = list(...)
#    ns = names(args)
#    for (i in seq_along(args)) {
#       name = ns[i]
#       obj = args[[i]]
#       hash = digest(c(digest(name), digest(obj)))
#       if (!exists(hash, envir=.BBmisc.parallel.hashes)) {
#         assign(hash, TRUE, envir=.BBmisc.parallel.hashes)
#        sfClusterCall(assign, name, obj, envir=globalenv())
#       }
#     }
# 	}
# }

