#' Maps a function over lists or vectors in parallel.
#'
#' Use the parallelization mode and the other options set in
#' \code{\link{parallelStart}}.
#'
#FIXME add later
# Large objects can be separately exported via \code{\link{parallelExport}},
# they can be simply used under their exported name in slave body code.
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

  if (isModeLocal() || !isParallelizationLevel(level) || getPMOptOnSlave()) {
    res = mapply(fun, ..., MoreArgs=more.args, SIMPLIFY=FALSE, USE.NAMES=FALSE)
  } else {
    iters = seq_along(..1)
    showInfoMessage("Doing a parallel mapping operation.")

    if (isModeMulticore()) {
      more.args = c(list(.fun = fun, .logdir=logdir), more.args)
      res = parallel::mcmapply(slaveWrapper, ..., .i = iters, MoreArgs=more.args, mc.cores=cpus,
                               SIMPLIFY=FALSE, USE.NAMES=FALSE)
      # produces list of try-error objects in case of error
      checkResultsAndStopWithErrorsMessages(res)
    } else if (isModeSocket() || isModeMPI()) {
      more.args = c(list(.fun = fun, .logdir=logdir), more.args)
      res = clusterMap(cl=NULL, slaveWrapper, ..., .i = iters, MoreArgs=more.args,
                       SIMPLIFY=FALSE, USE.NAMES=FALSE)
      # throws one single error on master in case of error
    } else if (isModeBatchJobs()) {
      # create registry in selected directory with random, unique name
      fd = getBatchJobsRegFileDir()
      # get packages to load on slaves which where collected in R option
      suppressMessages({
        reg = makeRegistry(id=basename(fd), file.dir=fd,
          packages=optionBatchsJobsPackages())
        # dont log extra in BatchJobs
        more.args = c(list(.fun = fun, .logdir=NA_character_), more.args)
        batchMap(reg, slaveWrapper, ..., more.args=more.args)
        # increase max.retries a bit, we dont want to abort here prematurely
        # if no resources set we submit with the default ones from the bj conf
        submitJobs(reg, resources=getPMOptBatchJobsResources(), max.retries=15)
        ok = waitForJobs(reg, stop.on.error=TRUE)
      })
      # copy log files of terminated jobs to designated dir
      if (!is.na(logdir)) {
        term = findTerminated(reg)
        fns = getLogFiles(reg, term)
        dests = file.path(logdir, sprintf("%05i.log", term))
        file.copy(from=fns, to=dests)
      }
      err.ids = findErrors(reg)
      if (length(err.ids) > 0) {
        extra.msg = sprintf("Please note that remaining jobs were killed when 1st error occured to save cluster time.\nIf you want to further debug errors, your BatchJobs registry is here:\n%s", fd)
        msgs = getBJErrorMessages(reg, err.ids)
        onsys = findOnSystem(reg)
        suppressMessages(
          killJobs(reg, onsys)
        )
        onsys = findOnSystem(reg)
        if (length(onsys) > 0L)
          warningf("Still %i jobs from operation on system! kill them manually!", length(onsys))
        stopWithJobErrorMessages(err.ids, msgs, extra.msg)
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

slaveWrapper = function(..., .i, .fun, .logdir=NA_character_) {
  if (!is.na(.logdir)) {
    options(warning.length=8170, warn=1)
    .fn = file.path(.logdir, sprintf("%05i.log", .i))
    .fn = file(.fn, open="wt")
    .start.time = as.integer(Sys.time())
    sink(.fn)
    sink(.fn, type="message")
    on.exit(sink(NULL))
  }
  
  # make sure we dont parallelize any further
  options(parallelMap.on.slave=TRUE)
  # just make sure, we should not have changed anything on the master
  # except for BatchJobs / interactive
  on.exit(options(parallelMap.on.slave=FALSE))
  
  res = .fun(...)

  if (!is.na(.logdir)) {
    .end.time = as.integer(Sys.time())
    print(gc())
    message(sprintf("Job time in seconds: %i", .end.time - .start.time))
    # I am not sure why i need to do this again, but without i crash in multicore
    sink(NULL)
  }
  return(res)
}
