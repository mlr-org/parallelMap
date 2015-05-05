#' Parallelization setup for parallelMap.
#'
#' Defines the underlying parallelization mode for \code{\link{parallelMap}}.
#' Also allows to set a \dQuote{level} of parallelization.
#' Only calls to \code{\link{parallelMap}} with a matching level are parallelized.
#' The defaults of all settings are taken from your options, which you can
#' also define in your R profile.
#' For an introductory tutorial and information on the options configuration, please
#' go to the project's github page at \url{https://github.com/berndbischl/parallelMap}.
#'
#' Currently the following modes are supported, which internally dispatch the mapping operation
#' to functions from different parallelization packages:
#'
#' \describe{
#' \item{local}{No parallelization with \code{\link{mapply}}.}
#' \item{multicore}{Multicore execution on a single machine with \code{\link[parallel]{mclapply}}.}
# \item{socket}{Socket cluster on one or multiple machines with \code{\link[parallel]{makePSOCKcluster}} and \code{\link[parallel]{clusterMap}}.}
#' \item{mpi}{Snow MPI cluster on one or multiple machines with \code{\link[parallel]{makeCluster}} and \code{\link[parallel]{clusterMap}}.}
#' \item{BatchJobs}{Parallelization on batch queuing HPC clusters, e.g., Torque, SLURM, etc., with \code{\link[BatchJobs]{batchMap}}.}
#' }
#'
#' For BatchJobs mode you need to define a storage directory through the argument \code{storagedir} or
#' the option \code{parallelMap.default.storagedir}.
#'
#' @param mode [\code{character(1)}]\cr
#'   Which parallel mode should be used:
#'   \dQuote{local}, \dQuote{multicore}, \dQuote{socket}, \dQuote{mpi}, \dQuote{BatchJobs}.
#'   Default is the option \code{parallelMap.default.mode} or, if not set,
#'   \dQuote{local} without parallel execution.
#' @param cpus [\code{integer(1)}]\cr
#'   Number of used cpus.
#'   For local and BatchJobs mode this argument is ignored.
#'   For socket mode, this is the number of processes spawned on localhost, if
#'   you want processes on multiple machines use \code{socket.hosts}.
#'   Default is the option \code{parallelMap.default.cpus} or, if not set,
#'   \code{\link[parallel]{detectCores}} for multicore mode,
#'   \code{\link[Rmpi]{mpi.universe.size}} for mpi mode
#'   and 1 for socket mode.
#' @param socket.hosts [\code{character}]\cr
#'   Only used in socket mode, otherwise ignored.
#'   Names of hosts where parallel processes are spawned.
#'   Default is the option \code{parallelMap.default.socket.hosts}, if this option exists.
#' @param bj.resources [\code{list}]\cr
#'   Resources like walltime for submitting jobs on HPC clusters via BatchJobs.
#'   See \code{\link[BatchJobs]{submitJobs}}.
#'   Defaults are taken from your BatchJobs config file.
#' @param logging [\code{logical(1)}]\cr
#'   Should slave output be logged to files via \code{\link{sink}} under the \code{storagedir}?
#'   Files are named "<iteration_number>.log" and put into unique
#'   subdirectories named \dQuote{parallelMap_log_<nr>} for each subsequent
#'   \code{\link{parallelMap}} operation.
#'   Previous logging directories are removed on \code{parallelStart}
#'   if \code{logging} is enabled.
#'   Logging is not supported for local mode, because you will see all
#'   output on the master and can also run stuff like
#'   \code{\link{traceback}} in case of errors.
#'   Default is the option \code{parallelMap.default.logging} or, if not set,
#'   \code{FALSE}.
#' @param storagedir [\code{character(1)}]\cr
#'   Existing directory where log files and intermediate objects for BatchJobs
#'   mode are stored.
#'   Note that all nodes must have write access to exactly this path.
#'   Default is the current working directory.
#' @param level [\code{character(1)}]\cr
#'   You can set this so only calls to \code{\link{parallelMap}} that have exactly the same level are parallelized.
#'   Default is the option \code{parallelMap.default.level} or, if not set,
#'   \code{NA} which means all calls to \code{\link{parallelMap}} are are potentially parallelized.
#' @param show.info [\code{logical(1)}]\cr
#'   Verbose output on console for all further package calls?
#'   Default is the option \code{parallelMap.default.show.info} or, if not set,
#'   \code{TRUE}.
#' @param suppress.local.errors [\code{logical(1)}]\cr
#'   Should reporting of error messages during function evaluations in local mode be suppressed?
#'   Default ist FALSE, i.e. every error message is shown.
#' @param ... [any]\cr
#'   Optional parameters, for socket mode passed to \code{\link[parallel]{makePSOCKcluster}},
#'   for mpi mode passed to \code{\link[parallel]{makeCluster}} and for multicore
#'   passed to \code{\link[parallel]{mcmapply}} (\code{mc.preschedule}, \code{mc.set.seed},
#'   \code{mc.silent} and \code{mc.cleanup} are supported for multicore).
#' @return Nothing.
#' @export
parallelStart = function(mode, cpus, socket.hosts, bj.resources = list(), logging, storagedir, level, show.info,
  suppress.local.errors = FALSE, ...) {
  # if stop was not called, warn and do it now
  if (isStatusStarted() && !isModeLocal()) {
    warningf("Parallelization was not stopped, doing it now.")
    parallelStop()
  }

  #FIXME: what should we do onexit if an error happens in this function?

  mode = getPMDefOptMode(mode)
  cpus = getPMDefOptCpus(cpus)
  socket.hosts = getPMDefOptSocketHosts(socket.hosts)

  level = getPMDefOptLevel(level)
  rlevls = parallelGetRegisteredLevels(flatten = TRUE)
  if (!is.na(level) && level %nin% rlevls) {
    warningf("Selected level='%s' not registered! This is likely an error! Note that you can also
      register custom levels yourself to get rid of this warning, see ?parallelRegisterLevels.R",
      level)
  }
  logging = getPMDefOptLogging(logging)
  storagedir = getPMDefOptStorageDir(storagedir)
  # defaults are in batchjobs conf
  assertList(bj.resources)
  show.info = getPMDefOptShowInfo(show.info)

  # multicore not supported on windows
  if (mode == MODE_MULTICORE && .Platform$OS.type == "windows")
    stop("Multicore mode not supported on windows!")
  assertDirectory(storagedir, access = "w")

  # store options for session, we already need them for helper funs below
  options(parallelMap.mode = mode)
  options(parallelMap.level = level)
  options(parallelMap.logging = logging)
  options(parallelMap.storagedir = storagedir)
  options(parallelMap.bj.resources = bj.resources)
  options(parallelMap.show.info = show.info)
  options(parallelMap.status = STATUS_STARTED)
  options(parallelMap.nextmap = 1L)
  options(parallelMap.suppress.local.errors = suppress.local.errors)

  # try to autodetect cpus if not set
  if (is.na(cpus) && mode %in% c(MODE_MULTICORE, MODE_MPI))
    cpus = autodetectCpus(mode)
  if (isModeSocket()) {
    if(!is.na(cpus) && !is.null(socket.hosts))
      stopf("You cannot set both cpus and socket.hosts in socket mode!")
    if(is.na(cpus) && is.null(socket.hosts))
      cpus = 1L
  }
  if (isModeLocal()) {
    if (!is.na(cpus))
      stopf("Setting %i cpus makes no sense for local mode!", cpus)
  }

  options(parallelMap.cpus = cpus)

  showStartupMsg(mode, cpus, socket.hosts)

  # now load extra packs we need
  requirePackages(getExtraPackages(mode), why = "parallelStart")

  # delete log dirs from previous runs
  if (logging) {
    if (isModeLocal())
      stop("Logging not supported for local mode!")
    deleteAllLogDirs()
  }

  # init parallel packs / modes, if necessary
  if (isModeMulticore()) {
    cl = makeMulticoreCluster(...)
  } else if (isModeSocket()) {
    # set names from cpus or socket.hosts, only 1 can be defined here
    if (is.na(cpus)) {
      names = socket.hosts
    } else {
      names = cpus
    }
    cl = makePSOCKcluster(names = names, ...)
    setDefaultCluster(cl)
  } else if (isModeMPI()) {
    cl = makeCluster(spec = cpus, type = "MPI", ...)
    setDefaultCluster(cl)
    clusterSetRNGStream(cl = NULL)
  } else if (isModeBatchJobs()) {
    # create registry in selected directory with random, unique name
    fd = getBatchJobsNewRegFileDir()
    wd = getwd()
    suppressMessages({
      reg = BatchJobs::makeRegistry(id = basename(fd), file.dir = fd, work.dir = wd)
    })
  }
  invisible(NULL)
}

#' @export
#' @rdname parallelStart
parallelStartLocal = function(show.info, suppress.local.errors = FALSE) {
  parallelStart(mode = MODE_LOCAL, cpus = NA_integer_, level = NA_character_,
    logging = FALSE, show.info = show.info, suppress.local.errors = suppress.local.errors)
}

#' @export
#' @rdname parallelStart
parallelStartMulticore = function(cpus, logging, storagedir, level, show.info, ...) {
  parallelStart(mode = MODE_MULTICORE, cpus = cpus, level = level, logging = logging,
    storagedir = storagedir, show.info = show.info, ...)
}

#' @export
#' @rdname parallelStart
parallelStartSocket = function(cpus, socket.hosts, logging, storagedir, level, show.info, ...) {
  parallelStart(mode = MODE_SOCKET, cpus = cpus, socket.hosts = socket.hosts, level = level, logging = logging,
    storagedir = storagedir, show.info = show.info, ...)
}

#' @export
#' @rdname parallelStart
parallelStartMPI = function(cpus, logging, storagedir, level, show.info, ...) {
  parallelStart(mode = MODE_MPI, cpus = cpus, level = level, logging = logging,
    storagedir = storagedir, show.info = show.info, ...)
}

#' @export
#' @rdname parallelStart
parallelStartBatchJobs = function(bj.resources = list(), logging, storagedir, level, show.info) {
  parallelStart(mode = MODE_BATCHJOBS, level = level, logging = logging,
    storagedir = storagedir, bj.resources = bj.resources, show.info = show.info)
}
