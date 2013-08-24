#' Maps a function over lists or vectors in parallel.
#'
#' Use the parallelization mode and the other options set in
#' \code{\link{parallelStart}}.
#'
#' Large objects can be separately exported via \code{\link{parallelExport}},
#' they can be simply used under their exported name in slave body code.
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
#'   of class character?
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
parallelMap = function(fun, ..., more.args=list(), simplify=FALSE, use.names=FALSE, level=as.character(NA)) {
  checkArg(fun, "function")
  checkArg(more.args, "list")
  checkArg(simplify, "logical", len=1L, na.ok=FALSE)
  checkArg(use.names, "logical", len=1L, na.ok=FALSE)
  checkArg(level, "character", len=1L, na.ok=TRUE)
  
  mode = getPMOptMode()
  cpus = getPMOptCpus()
  lev = getPMOptLevel()
  logging = getPMOptLogging()
  # use NA to encode "no logging" in logdir
  logdir = ifelse(logging, getNextLogDir(), NA_character_)
  show.info = getPMOptShowInfo()
  
  # potentially autostart by calling parallelStart with defaults from R profile
  # then clean up by calling parallelStop on exit
  if (getPMDefOptAutostart() && isStatusStopped() && !isModeLocal()) {
    showInfoMessage("Auto-starting parallelization.")
    parallelStart()
    on.exit({
      if (!isModeLocal())
        showInfoMessage("Auto-stopping parallelization.")
      parallelStop()
    })
  }

  if (isModeLocal() || !isParallelizationLevel(level)) {
    res = mapply(fun, ..., MoreArgs=more.args, SIMPLIFY=FALSE, USE.NAMES=FALSE)
  } else {
    messagef("Doing a parallel mapping operation.")
    iters = seq_along(..1)
    toList = function(...) {
      Map(function(iter, ...) {
        c(list(iter), list(...), more.args)
      }, iters, ...)
    }
    if (isModeMulticore()) {
      res = parallel::mclapply(toList(...), FUN=slaveWrapper, mc.cores=cpus, mc.allow.recursive=FALSE, .fun=fun, .logdir=logdir)
      # produces list of try-error objects in case of error
      checkForAndDisplayErrors(res)
    } else if (isModeSocket()) {
      res = clusterApplyLB(cl=NULL, toList(...), fun=slaveWrapper, .fun=fun, .logdir=logdir)
      # throws one single error on master in case of error
      #res = clusterMap(cl=NULL, fun, ..., MoreArgs=more.args, SIMPLIFY=FALSE, USE.NAMES=FALSE)
      #checkForAndDisplayErrors(res)
    } else if (isModeMPI()) {
      res = clusterApplyLB(cl=NULL, toList(...), fun=slaveWrapper, .fun=fun, .logdir=logdir)
      # throws one single error on master in case of error
    } else if (isModeBatchJobs()) {
      # create registry in selected directory with random, unique name
      fd = getBatchJobsRegFileDir()
      # get packages to load on slaves which where collected in R option
      reg = makeRegistry(id=basename(fd), file.dir=fd, 
        packages=optionBatchsJobsPackages())
      batchMap(reg, fun, ..., more.args=more.args)
      # increase max.retries a bit, we dont want to abort here prematurely
      # if no resources set we submit with the default ones from the bj conf 
      submitJobs(reg, resources=getPMOptBatchJobsResources(), max.retries=15)
      # FIXME stop on err?
      waitForJobs(reg)
      # copy log files to designated dir
      if (!is.na(logdir)) {
        fns = getLogFiles(reg)
        dests = file.path(logdir, sprintf("%05i.log", getJobIds(reg)))
        file.copy(from=fns, to=dests)
      }
      err.ids = findErrors(reg)
      if (length(err.ids) > 0) {
        msg = sprintf("If you want to further debug errors, your BatchJobs registry is here:\n%s", fd)
        displayErrorMessages(err.ids, getBJErrorMessages(reg, err.ids), msg)
      }
      res = loadResults(reg, simplify=FALSE, use.names=FALSE)
      # delete registry file dir, if an error happened this will still exist
      # because we threw an exception above, logs also still exist
      unlink(fd, recursive=TRUE)
    }
  }

  if (use.names && is.character(..1)) {
    names(res) = ..1
  }
  if (!use.names) {
    names(res) = NULL
  }
  if (isTRUE(simplify) && length(res) > 0)
    res = simplify2array(res, higher=(simplify == "array"))
  
  # count number of mapping operations for log dir
  options(parallelMap.nextmap = (getPMOptNextMap() + 1L))
  
  return(res)
}

slaveWrapper = function(.x, .fun, .logdir=NA_character_) {
  if (!is.na(.logdir)) {
    options(warning.length=8170, warn=1)
    .fn = file.path(.logdir, sprintf("%05i.log", .x[[1]]))
    .fn = file(.fn, open="wt")
    .start.time = as.integer(Sys.time())
    sink(.fn)
    sink(.fn, type="message")
  }

  res = do.call(.fun, .x[-1])

  if (!is.na(.logdir)) {
    .end.time = as.integer(Sys.time())    
    print(gc())
    message(sprintf("Job time in seconds: %i", .end.time - .start.time))
    sink(NULL)
  }
  return(res)
}
