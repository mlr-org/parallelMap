#' Parallelization setup for parallelMap.
#'
#' Defines the underlying parallelization mode for \code{\link{parallelMap}} 
#' and allows to set a \dQuote{level} of parallelization.
#' Only calls to \code{\link{parallelMap}} with a matching level are parallelized.
#' 
#' Currently the following modes are supported:
#' 
#' \describe{
#' \item{local}{No paralleliaztion by dispatching to \code{\link{mapply}}}.
#' \item{multicore}{Multicore execution by dispatching to \code{\link[parallel]{mclapply}}}.
#' \item{socket}{Multicore execution by dispatching to \code{\link[parallel]{mclapply}}}.
#' \item{snowfall}{Multicore execution by dispatching to \code{\link[snowfall]{sfClusterApplyLB}}}.
#' \item{BatchJobs}{Multicore execution by dispatching to \code{\link[BatchJobs]{batchMap}}}.
#' }
#' 
#' For snowfall \code{\link[snowfall]{sfSetMaxCPUs}}, 
#' \code{\link[snowfall]{sfInit}}, \code{\link[snowfall]{sfClusterSetupRNG}}
#' are called in this order.
#'
#' The defaults of all settings are taken from your options
#' You can define defaullt for all options in your R profile like this:
#' 
#' \code{options(parallelMap.default.mode = "multicore")}
#' \code{options(parallelMap.default.cpus = 4L)}
#' \code{options(parallelMap.default.level = NA)}
#' \code{options(parallelMap.default.log = "~/mylogs")}
#' \code{options(parallelMap.default.autostart = TRUE)}
#'
#' @param mode [\code{character(1)}]\cr
#'   Which parallel mode should be used:
#'   \dQuote{local}, \dQuote{multicore}, \dQuote{snowfall}.
#'   Default is the option \code{parallelMap.default.mode} or, if not set, 
#'   \dQuote{local} without parallel execution.
#' @param cpus [\code{integer(1)}]\cr
#'   Number of used cpus.
#'   Default is the option \code{parallelMap.default.cpus} or, if not set,
#'   \code{\link[parallel]{detectCores}} for multicore, 
#'   \code{\link[Rmpi]{mpi.universe.size}} for snowfall/MPI
#'   and 1 otherwise.
#' @param ... [any]\cr
#'    Optional parameters, only passed to \code{\link[snowfall]{sfInit}} currently.
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
   status = getOption("parallelMap.status")
   if (status != "stopped")   {
    warningf("Parallelization was not stopped, doing it now.")
    parallelStop()
  }
  
  if (missing(mode)) {
    mode = getOption("parallelMap.mode", "local")
  }
  checkArg(mode, choices=c("local", "multicore", "socket", "snowfall", "BatchJobs"))
  
  # try to autodetect cpus if not set 
  if (missing(cpus)) {
    cpus = getOption("parallelMap.cpus")
    if (is.null(cpus)) {
      if (mode == "multicore")
        cpus = parallel::detectCores()
      else if(mode=="snowfall" && type=="MPI")
        cpus = Rmpi::mpi.universe.size()
      else
        cpus = 1L
    }
  }
  cpus = convertInteger(cpus)
  checkArg(cpus, "integer", len=1, na.ok=FALSE)

  #FIXME do we really need this check?
#    if (cpus != 1L && mode == "local")
#      stopf("Setting %i cpus makes no sense for local mode!", cpus)

  if (missing(level)) {
    level = getOption("parallelMap.level", as.character(NA))
  }
  checkArg(level, "character", len=1, na.ok=TRUE)

  if (missing(log)) {
    log = getOption("parallelMap.log", as.character(NA))
  }
  checkArg(log, "character", len=1, na.ok=TRUE)
  
  autostart = getOption("parallelMap.default.autostart", TRUE)
  checkArg(autostart, "logical", len=1L, na.ok=FALSE)

  if (missing(show.info)) {
    show.info = getOption("parallelMap.default.show.info", TRUE)
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

  type = coalesce(..., "SOCK")

  # now load extra packs we need
  packs = if (mode == "multicore")
    "parallel"
  else if (mode == "snowfall")
    if (type == "MPI")
      c("snowfall", "Rmpi")
  else
    "snowfall"
  else if (mode == "BatchJobs")
    "BatchJobs"
  else
    character(0)
  requirePackages(packs, "parallelStart")

  # init parallel packs / modes, if necessary 
  if (mode == "socket") {
    args = argsAsNamedList(...)
    if ("names" %nin% names(args))
      cl = makePSOCKcluster(names = cpus, ...)
    else
      cl = makePSOCKcluster(...)
    setDefaultCluster(cl)
  } else if (mode == "snowfall") {
    sfSetMaxCPUs(cpus)
    sfInit(parallel=TRUE, cpus=cpus, ...)
    sfClusterSetupRNG()
  } else if (mode == "BatchJobs") {
    # FIXME do nothing?
  }
  # store options for session
  options(parallelMap.mode = mode)
  options(parallelMap.cpus = cpus)
  options(parallelMap.level = level)
  options(parallelMap.log = log)
  options(parallelMap.show.info = show.info)
  options(parallelMap.autostart = autostart)
  options(parallelMap.status = "started")
  invisible(NULL)
}
