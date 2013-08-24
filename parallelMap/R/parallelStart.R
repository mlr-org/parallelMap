#' Parallelization setup for parallelMap.
#'
#' Defines the underlying parallelization mode for \code{\link{parallelMap}} 
#' and allows to set a \dQuote{level} of parallelization.
#' Only calls to \code{\link{parallelMap}} with a matching level are parallelized.
#' 
#' The defaults of all settings are taken from your options, which you can
#' also define in your R profile.
#' 
#' For an introductory tutorial and information on the options configuration, please
#' go to the project's github page at:
#FIXME explean in wiki page
#' \url{http://www.github.com}
#'
#' Currently the following modes are supported, which internally dispatch the mapping operation
#' to functions from different parallelization packages:
#' 
#' \describe{
#' \item{local}{No parallelization with \code{\link{mapply}}.}
#' \item{multicore}{Multicore execution on a single machine with\code{\link[parallel]{mclapply}}.}
#' \item{socket}{Socket cluster on one or multiple machines with \code{\link[parallel]{makePSOCKcluster}} and \code{\link[parallel]{clusterMap}}.}
#' \item{snowfall}{Snow MPI cluster with \code{\link[snowfall]{sfClusterApplyLB}}.}
#' \item{BatchJobs}{Parallelization on batch queuing HPC clusters, e.g., Torque, SLURM, etc., by with \code{\link[BatchJobs]{batchMap}}.}
#' }
#' 
#' For BatchJobs you need to define a storage directory through the argument storagedir or
#' the option \code{parallelMap.storagedir}
#' 
#' For snowfall \code{\link[snowfall]{sfSetMaxCPUs}}, 
#' \code{\link[snowfall]{sfInit}}, \code{\link[snowfall]{sfClusterSetupRNG}}
#' are called in this order.
#'
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
#' @param logging [\code{logical(1)}]\cr
#'   Should slave output be logged to files via \code{\link{sink}} in the \code{storagedir}?
#'   Files are named "<iteration_number>.log".
#'   Default is the option \code{parallelMap.default.logging} or, if not set,
#'   \code{FALSE}.
#' @param storagedir [\code{character(1)}]\cr
#'   Existing directory where log files and intermediate objects for BatchsJobs
#'   mode are stored.
#'   Note that all nodes must have write access to exactly this path.
#'   Default is the current working directory.
#' @param show.info [\code{logical(1)}]\cr
#'   Verbose output on console?
#'   Default is the option \code{parallelMap.default.show.info} or, if not set, 
#'   \code{TRUE}.
#' @return Nothing.
#' @export
parallelStart = function(mode, cpus, ..., level, logging, storagedir, bj.resources, show.info) {
  # if stop was not called, warn and do it now
  if (isStatusStarted() && !isModeLocal()) {
    warningf("Parallelization was not stopped, doing it now.")
    parallelStop()
  }
  
  mode = getPMDefOptMode(mode)
  cpus = getPMDefOptCpus(cpus)
  level = getPMDefOptLevel(level)
  logging = getPMDefOptLogging(logging)
  storagedir = getPMDefOptStorageDir(storagedir)
  show.info = getPMDefOptShowInfo(show.info)
  autostart = getPMDefOptAutostart()
  
  #FIXME do we really need this check?
  #    if (cpus != 1L && mode == "local")
  #      stopf("Setting %i cpus makes no sense for local mode!", cpus)
  
  # check that storagedir is indeed a valid dir 
  checkDir("Storage", storagedir)
  # FIXME document 
  #if (mode=="local")
  #  stop("Logging not supported for local mode!")
  
  # store options for session, we already need them for helper funs below
  options(parallelMap.autostart = autostart)
  options(parallelMap.mode = mode)
  options(parallelMap.level = level)
  options(parallelMap.logging = logging)
  options(parallelMap.storagedir = storagedir)
  options(parallelMap.show.info = show.info)
  options(parallelMap.status = STATUS_STARTED)   
  
  
  # try to autodetect cpus if not set 
  if (is.na(cpus))
    cpus = autodetectCpus(mode)
  options(parallelMap.cpus = cpus)
  
  # FIXME make message nicer for modes
  if (!isModeLocal()) 
    showInfoMessage("Starting parallelization in mode=%s with cpus=%i.", mode, cpus)
  
  # now load extra packs we need
  requirePackages(getExtraPackages(mode), "parallelStart")
  
  # init parallel packs / modes, if necessary 
  if (isModeSocket()) {
    args = argsAsNamedList(...)
    if ("names" %nin% names(args))
      cl = makePSOCKcluster(names = cpus, ...)
    else
      cl = makePSOCKcluster(...)
    setDefaultCluster(cl)
  } else if (isModeMPI()) {
    sfSetMaxCPUs(cpus)
    sfInit(parallel=TRUE, cpus=cpus, ...)
    sfClusterSetupRNG()
  } else if (isModeBatchJobs()) {
    #FIXME handle resourcses
    dir.create(getBatchJobsExportsDir())
  }
  
  invisible(NULL)
}
