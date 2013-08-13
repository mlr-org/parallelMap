#' Parallelization setup for parallelMap.
#'
#' Defines the underlying parallelization mode (currently parallel/multicore or snowfall) for
#' \code{\link{parallelMap}} and allows to set a \dQuote{level} of parallelization.
#' Only calls to \code{\link{parallelMap}} with a matching level are parallelized.
#'
#' For snowfall \code{\link[snowfall]{sfStop}}, \code{\link[snowfall]{sfSetMaxCPUs}}, 
#' \code{\link[snowfall]{sfInit}}, \code{\link[snowfall]{sfClusterSetupRNG}}
#' are called in this order.
#'
#' @param mode [\code{character(1)}]\cr
#'   Which parallel mode should be used:
#'   \dQuote{local}, \dQuote{multicore}, \dQuote{snowfall}.
#'   Default is \dQuote{local} without parallel execution.
#' @param cpus [\code{integer(1)}]\cr
#'   Number of used cpus.
#'   Default is \code{\link[Rmpi]{mpi.universe.size}} for snowfall/MPI and 1 otherwise.
#' @param ... [any]\cr
#'    Optional parameters, only passed to \code{\link[snowfall]{sfInit}} currently.
#' @param level [\code{character(1)}]\cr
#'   You can set this so only calls to \code{\link{parallelMap}} are parallelized
#'   that have the same level specified.
#'   Default is \code{NA} which means all calls are parallelized.
#' @param log [\code{character(1)}]\cr
#'   Path to an existing directory where a log files for each job is stored via
#'   \code{\link{sink}}. Note that all nodes must have write access to exactly this path.
#'   Files are named "<iteration_number>.log".
#'   \code{NULL} means no logging and this is the default.
#' @return Nothing.
#' @export
parallelStart = function(mode="local", cpus, ..., level=as.character(NA), log=NULL) {
  checkArg(mode, choices=c("local", "multicore", "snowfall", "BatchJobs"))
  
  if (missing(cpus)) {
    if (mode == "multicore")
      cpus = parallel::detectCores()
    else if(mode=="snowfall" && type=="MPI")
      cpus = Rmpi::mpi.universe.size()
    else
      cpus = 1L
  } else {
    cpus = convertInteger(cpus)
    checkArg(cpus, "integer", len=1, na.ok=FALSE)
    if (cpus != 1L && mode == "local")
      stopf("Setting %i cpus makes no sense for local mode!", cpus)
  }
  checkArg(level, "character", len=1, na.ok=TRUE)
  if (!is.null(log)) {
    checkArg(log, "character", len=1, na.ok=FALSE)
    if (!file.exists(log))
      stopf("Logging dir 'log' does not exists: %s", log)
    if (!isDirectory(log))
      stopf("Logging dir 'log' is not a directory: %s", log)
    if (mode=="local")
      stop("Logging not supported for local mode!")
  }
  
  type = coalesce(..., "SOCK")
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
  requirePackages(packs, "setupParallel")
  if (mode == "snowfall") {
    sfStop()
    sfSetMaxCPUs(cpus)
    sfInit(parallel=TRUE, cpus=cpus, ...)
    sfClusterSetupRNG()
  } else if (mode == "BatchJobs") {
    fd = "bbmisc_parallel_bj_files"
    unlink(fd, recursive = TRUE)
    reg = makeRegistry("BBmisc_parallel", file.dir=fd)
    options(BBmisc.parallel.bj.reg.file.path = reg$file.dir)
  }
  options(BBmisc.parallel.mode = mode)
  options(BBmisc.parallel.cpus = cpus)
  options(BBmisc.parallel.level = level)
  options(BBmisc.parallel.log = log)
  invisible(NULL)
}
