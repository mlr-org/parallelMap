#' @title Maps a function over lists or vectors in parallel.
#'
#' @description
#' Uses the parallelization mode and the other options specified in
#' \code{\link{parallelStart}}.
#'
#' Libraries and source file can be initialized on slaves with
#' \code{\link{parallelLibrary}} and \code{\link{parallelSource}}.
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
#'   If a (non-missing) level is specified in \code{\link{parallelStart}},
#'   this call is only parallelized if the level specified here matches.
#'   Useful if this function is used in a package.
#'   Default is \code{NA}.
#' @param show.info [\code{logical(1)}]\cr
#'   Verbose output on console?
#'   Can be used to override setting from options / \code{\link{parallelStart}}.
#'   Default is NA which means no overriding.
#' @return Result.
#' @export
#' @examples
#' parallelStart()
#' parallelMap(identity, 1:2)
#' parallelStop()
parallelMap = function(fun, ..., more.args=list(), simplify=FALSE, use.names=FALSE,
  level=as.character(NA), show.info=NA) {

  checkArg(fun, "function")
  checkArg(more.args, "list")
  checkArg(simplify, "logical", len=1L, na.ok=FALSE)
  checkArg(use.names, "logical", len=1L, na.ok=FALSE)
  checkArg(level, "character", len=1L, na.ok=TRUE)
  checkArg(show.info, "logical", len=1L, na.ok=TRUE)

  # potentially autostart by calling parallelStart with defaults from R profile
  # then clean up by calling parallelStop on exit
  if (getPMDefOptAutostart() && isStatusStopped() && getPMDefOptMode() != MODE_LOCAL) {
    showInfoMessage("Auto-starting parallelization.")
    parallelStart()
    on.exit({
      if (!isModeLocal())
        showInfoMessage("Auto-stopping parallelization.", show.info=show.info)
      parallelStop()
    })
  }

  cpus = getPMOptCpus()
  logging = getPMOptLogging()
  # use NA to encode "no logging" in logdir
  logdir = ifelse(logging, getNextLogDir(), NA_character_)

  if (isModeLocal() || !isParallelizationLevel(level) || getPMOptOnSlave()) {
    res = mapply(fun, ..., MoreArgs=more.args, SIMPLIFY=FALSE, USE.NAMES=FALSE)
  } else {
    iters = seq_along(..1)
    showInfoMessage("Mapping in parallel: mode=%s; cpus=%i; elements=%i.",
      getPMOptMode(), getPMOptCpus(), length(iters))

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
      fd = getBatchJobsRegFileDir()
      # FIXME: this is bad but currently we cannot use absolute paths
      src.files = optionBatchsJobsSrcFiles()
      wd = getPMOptStorageDir()
      srcdir = tempfile(pattern="parallelMap_BatchJobs_srcs_", tmpdir=wd)
      dir.create(srcdir)
      file.copy(from=src.files, to=srcdir)
      # create registry in selected directory with random, unique name
      suppressMessages({
        reg = makeRegistry(id=basename(fd), file.dir=fd, work.dir=wd,
          # get packages and sources to load on slaves which where collected in R option
          packages=optionBatchsJobsPackages(),
          src.files=paste(basename(srcdir), basename(src.files), sep="/")
        )
        file.exports = list.files(getBatchJobsExportsDir(), full.names=TRUE)
        file.rename(from=file.exports,
          to=file.path(BatchJobs:::getExportDir(reg$file.dir), basename(file.exports)))
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
        msgs = BatchJobs::getErrorMessages(reg, err.ids)
        onsys = findOnSystem(reg)
        suppressMessages(
          killJobs(reg, onsys)
        )
        onsys = findOnSystem(reg)
        if (length(onsys) > 0L)
          warningf("Still %i jobs from operation on system! kill them manually!", length(onsys))
        stopWithJobErrorMessages(err.ids, msgs, extra.msg)
      }
      expired.ids = findExpired(reg)
      if (length(expired.ids) > 0) {
        stop("Some Jobs expired and did not generate any results. Partail results are not supported yet.")
      }
      res = loadResults(reg, simplify=FALSE, use.names=FALSE)
      # delete registry file dir, if an error happened this will still exist
      # because we threw an exception above, logs also still exist
      unlink(fd, recursive=TRUE)
      #FIXME: see above about src.files
      unlink(srcdir, recursive=TRUE)
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
