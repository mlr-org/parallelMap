#' Maps a function over lists or vectors in parallel.
#'
#' Use the parallelization mode and the other options set in
#' \code{\link{parallelStart}}. For parallel/multicore \code{\link[parallel]{mclapply}}
#' is used, for snowfall \code{\link[snowfall]{sfClusterApplyLB}}.
#'
#' Large objects should be separately exported via \code{\link{parallelExport}},
#' they can be simply used under their exported name in slave body code.
#'
#' Note that there is a bug in \code{\link[parallel]{mclapply}} of parallel because exceptions raised
#' during slave calls are not corretly converted to try-errror objects (as claimed in the documentation) but
#' instead a warning is generated. Because of this, \code{parallelMap} does not generate an exception in this
#' case either.
#'
#' @param fun [\code{function}]\cr
#'   Function to map over \code{...}.
#' @param ... [any]\cr
#'   Arguments to vectorize over (list or vector).
#' @param more.args [\code{list}]\cr
#'   A list of other arguments passed to \code{fun}.
#'   Default is empty list.
#' @param simplify [\code{logical(1)}]\cr
#'   Should the result be simplified?
#'   See \code{\link{sapply}}.
#'   Default is \code{FALSE}.
#' @param use.names [\code{logical(1)}]\cr
#'   Should result be named by first vector if that is
#'   of class character or integer?
#'   Default is \code{FALSE}.
#' @param level [\code{character(1)}]\cr
#'   The call is only parallelized if the same level is specified in
#'   \code{\link{parallelStart}} or this argument is \code{NA}.
#'   Default is \code{NA}.
#' @return Result.
#' @export
#' @examples
#' parallelStart()
#' parallelMap(identity, 1:2)
#' parallelStop()
#FIXME what happens with log files after multiple calls of parallelMap? 
parallelMap = function(fun, ..., more.args=list(), simplify=FALSE, use.names=FALSE, level=as.character(NA)) {
  checkArg(fun, "function")
  checkArg(more.args, "list")
  checkArg(simplify, "logical", len=1L, na.ok=FALSE)
  checkArg(use.names, "logical", len=1L, na.ok=FALSE)
  checkArg(level, "character", len=1L, na.ok=TRUE)
  
  status = getOption("parallelMap.status")
  autostart = getOption("parallelMap.default.autostart", TRUE)
  if(!is.null(autostart)) {
    checkArg(autostart, "logical", len=1L, na.ok=FALSE)
  }
  mode = getOption("parallelMap.mode")
  cpus = getOption("parallelMap.cpus")
  lev = getOption("parallelMap.level")
  log = getOption("parallelMap.log")
  show.info = getOption("parallelMap.show.info")
  
  # potentially autostart by calling parallelStart with defaults from R profile
  # then clean up by calling parallelStop on exit
  if (status != "started" && autostart && mode != "local") {
    messagef("Auto-starting parallelization.")
    parallelStart()
    on.exit({
      if (mode != "local")
        messagef("Auto-stopping parallelization.")
      parallelStop()
    })
  }

  if (mode == "local" || (!is.na(lev) && !is.na(level) && level != lev)) {
    res = mapply(fun, ..., MoreArgs=more.args, SIMPLIFY=FALSE, USE.NAMES=FALSE)
  } else {
    messagef("Doing a parallel mapping operation.")
    iters = seq_along(..1)
    toList = function(...) {
      Map(function(iter, ...) {
        c(list(iter), list(...), more.args)
      }, iters, ...)
    }
    if (mode == "multicore") {
      res = parallel::mclapply(toList(...), FUN=slaveWrapper, mc.cores=cpus, mc.allow.recursive=FALSE, .fun=fun, .log=log)
      # FIXME helper fornext lines
      inds.err = sapply(res, is.error)
      if (any(inds.err))
        stop(collapse(c("\n", sapply(res[inds.err], as.character), sep="\n")))
    } else if (mode == "socket") {
      res = clusterApplyLB(cl=NULL, toList(...), fun=slaveWrapper, .fun=fun, .log=log)
      #res = clusterMap(cl=NULL, fun, ..., MoreArgs=more.args, SIMPLIFY=FALSE, USE.NAMES=FALSE)
      inds.err = sapply(res, is.error)
      if (any(inds.err))
        stop(collapse(c("\n", sapply(res[inds.err], as.character), sep="\n")))
    } else if (mode == "snowfall") {
      res = sfClusterApplyLB(toList(...), fun=slaveWrapper, .fun=fun, .log=log)
      #FIXME what happens with errors here?
    } else if (mode == "BatchJobs") {
      #FIXME option
      bj.dir = getwd()    
      # create registry in selected directory with random, unique name
      fd = tempfile(pattern="parallelMap_BatchJobs_reg_", tmpdir=bj.dir)
      id = basename(fd)
      if (file.exists(fd)) {
        stopf("BatchJobs registry file dir internally used by parallelMap already exists:\n%s", fd)
      }
      # get package name to load on slaves which where collected in R option
      bj.packs = getOption("parallelMap.bj.packages", character(0))
      reg = makeRegistry(id=id, file.dir=fd, packages=bj.packs)
      batchMap(reg, fun, ..., more.args=more.args)
      submitJobs(reg, max.retries=15)
      # FIXME stop on err?
      waitForJobs(reg)
      # copy log files to designated dir
      if (!is.na(log)) {
        fns = getLogFiles(reg)
        dests = file.path(log, sprintf("%05i.log", getJobIds(reg)))
        file.copy(from=fns, to=dests)
      }
      # FIXME: really show all errors? also check other places of same code
      if (length(findErrors(reg)) > 0) {
        # FIXME write
        messagef("Regitrsy is here:\n%s", fd)
        # FIXME in whih version of BJ is getterrmessages? is this on cran?
        stop(collapse(getErrorMessages(reg), sep="\n"))
      }
      res = loadResults(reg, simplify=FALSE, use.names=FALSE)
      # delete registry file dir, if an error happened this will still exist
      # because we threw an exception above, logs also still exist
      unlink(fd, recursive=TRUE)
    }
  }

  if (use.names && (is.character(..1) || is.integer(..1))) {
    names(res) = ..1
  }
  if (!use.names) {
    names(res) = NULL
  }
  if (isTRUE(simplify) && length(res) > 0)
    res = simplify2array(res, higher=(simplify == "array"))

  return(res)
}

slaveWrapper = function(.x, .fun, .log=as.character(NA)) {
  if (!is.na(.log)) {
    options(warning.length=8170, warn=1)
    fn = file.path(.log, sprintf("%05i.log", .x[[1]]))
    fn = file(fn, open="wt")
    sink(fn)
    sink(fn, type="message")
  }

  res = do.call(.fun, .x[-1])
  if (!is.na(.log)) {
    print(gc())
    sink(NULL)
  }
  return(res)
}
