#' Parallelization setup for parallelMap.
#'
#' Defines the underlying parallelization mode for \code{\link{parallelMap}} 
#' and allows to set a \dQuote{level} of parallelization.
#' Only calls to \code{\link{parallelMap}} with a matching level are parallelized.
#' 
#' Currently the following modes are supported:
#' 
#' \describe{
#' \item{local}{No paralleliaztion by dispatching to \code{\link{mapply}}.}
#' \item{multicore}{Multicore execution on a single machine by dispatching to \code{\link[parallel]{mclapply}}.}
#' \item{socket}{Socket cluster on one or multiple machines by dispatching to \code{\link[parallel]{makePSOCKcluster}} and \code{\link[parallel]{clusterMap}}.}
#' \item{snowfall}{Snow cluster, e.g. for MPI, by dispatching to \code{\link[snowfall]{sfClusterApplyLB}}.}
#' \item{BatchJobs}{Parallelization on batch queuing HPC clusters, e.g. Torque, SLURM, etc., by dispatching to \code{\link[BatchJobs]{batchMap}}.}
#' }
#' 
#' For snowfall \code{\link[snowfall]{sfSetMaxCPUs}}, 
#' \code{\link[snowfall]{sfInit}}, \code{\link[snowfall]{sfClusterSetupRNG}}
#' are called in this order.
#'
#' The defaults of all settings are taken from your options
#' You can define default for all options in your R profile like this
#FIXME explean in wiki page
#' \url{http://www.github.com}
#'
#' @param mode [\code{character(1)}]\cr
#'   Which parallel mode should be used:
#'   \dQuote{local}, \dQuote{multicore}, \dQuote{socket}, \dQuote{mpi}, \dQuote{BatchJobs}.
#'   Default is the option \code{parallelMap.default.mode} or, if not set, 
#'   \dQuote{local} without parallel execution.
#' @param cpus [\code{integer(1)}]\cr
#'   Number of used cpus.
#'   For local and BatchJobs mode this argument is ignored.
#'   Default is the option \code{parallelMap.default.cpus} or, if not set,
#'   \code{\link[parallel]{detectCores}} for multicore, 
#'   \code{\link[Rmpi]{mpi.universe.size}} for snowfall/MPI
#'   and 1 otherwise.
#' @param ... [any]\cr
#'   Optional parameters, for socket mode passed to \code{\link[parallel]{makePSOCKcluster}},
#'   for snowfall mode passed to \code{\link[snowfall]{sfInit}}.
#' @param level [\code{character(1)}]\cr
#'   You can set this so only calls to \code{\link{parallelMap}} are parallelized
#'   that have the same level specified.
#'   Default is the option \code{parallelMap.default.level} or, if not set, 
#'   \code{NA} which means all calls to \code{\link{parallelMap}} are are parallelized.
#' @param log [\code{character(1)}]\cr
#'   Path to an existing directory where a log files for each job is stored via
#'   \code{\link{sink}}. Note that all nodes must have write access to exactly this path.
#'   Files are named "<iteration_number>.log".
#'   Default is the option \code{parallelMap.default.log} or, if not set, 
#'   \code{NA} which means no logging.
#' @param show.info [\code{logical(1)}]\cr
#'   Verbose output on console?
#'   Default is the option \code{parallelMap.default.show.info} or, if not set, 
#'   \code{TRUE}.
#' @return Nothing.
#' @export
parallelStart = function(mode, cpus, ..., level, log, show.info) {
   # if stop was not called, warn and do it now
   if (isStatusStarted() && !isModeLocal()) {
    warningf("Parallelization was not stopped, doing it now.")
    parallelStop()
  }
  
  if (missing(mode)) {
    mode = getPMDefOptMode()
  }
  checkArg(mode, choices=MODES)
  
  # try to autodetect cpus if not set 
  if (missing(cpus)) {
    cpus = autodetectCpus(mode)
  }
  cpus = convertInteger(cpus)
  checkArg(cpus, "integer", len=1, na.ok=FALSE)

  #FIXME do we really need this check?
#    if (cpus != 1L && mode == "local")
#      stopf("Setting %i cpus makes no sense for local mode!", cpus)

  if (missing(level)) {
    level = getPMDefOptLevel()
  }
  checkArg(level, "character", len=1, na.ok=TRUE)

  if (missing(log)) {
    log = getPMDefOptLog()
  }
  checkArg(log, "character", len=1, na.ok=TRUE)
  
  #FIXME default?
  autostart = getPMDefOptAutostart()
  checkArg(autostart, "logical", len=1L, na.ok=FALSE)

  if (missing(show.info)) {
    show.info = getPMDefOptShowInfo()
  }
  checkArg(show.info, "logical", len=1L, na.ok=FALSE) 
  
  if (show.info && mode != "local") {
    messagef("Starting parallelization in mode=%s with cpus=%i.", mode, cpus)
  }
  
  # check that log is indeed a valid dir 
  if (!is.na(log)) {
    if (!file.exists(log))
      stopf("Logging dir 'log' does not exists: %s", log)
    if (!isDirectory(log))
      stopf("Logging dir 'log' is not a directory: %s", log)
    # FIXME document or still do?
    #if (mode=="local")
    #  stop("Logging not supported for local mode!")
  }
  
  ##### arg checks done #####

  # now load extra packs we need
   ss = getExtraPackages(mode)
   print(ss)
  requirePackages(ss, "parallelStart")

  # init parallel packs / modes, if necessary 
  switch(mode,
    MODE_SOCKET = {
      args = argsAsNamedList(...)
      if ("names" %nin% names(args))
        cl = makePSOCKcluster(names = cpus, ...)
      else
        cl = makePSOCKcluster(...)
      setDefaultCluster(cl)
    }, 
    MODE_MPI = {
      sfSetMaxCPUs(cpus)
      sfInit(parallel=TRUE, cpus=cpus, ...)
      sfClusterSetupRNG()
    },
    MODE_BATCHJOBS = {
      cleanUpBatchJobsExports()
    }
  )
  # store options for session
  options(parallelMap.mode = mode)
  options(parallelMap.cpus = cpus)
  options(parallelMap.level = level)
  options(parallelMap.log = log)
  options(parallelMap.show.info = show.info)
  options(parallelMap.autostart = autostart)
  options(parallelMap.status = STATUS_STARTED)
  invisible(NULL)
}
