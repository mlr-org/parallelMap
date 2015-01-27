#' @import BBmisc
#' @import checkmate
#' @import parallel

# define constants
MODE_LOCAL = "local"
MODE_MULTICORE = "multicore"
MODE_SOCKET = "socket"
MODE_MPI = "mpi"
MODE_BATCHJOBS = "BatchJobs"
MODES = c(MODE_LOCAL, MODE_MULTICORE, MODE_SOCKET, MODE_MPI, MODE_BATCHJOBS)

STATUS_STARTED = "started"
STATUS_STOPPED = "stopped"

PKG_LOCAL_ENV = new.env()

.MulticoreCluster = new.env()

.onLoad = function(libname, pkgname) {
  # init all settings from defaults
  # we cant call any function here in onload that dispatch to BBmisc...
  options(
    parallelMap.mode = getPMDefOption("mode", MODE_LOCAL),
    parallelMap.cpus = getPMDefOption("cpus", NA_integer_),
    parallelMap.socket.hosts = getPMDefOption("socket.hosts", NULL),
    parallelMap.level = getPMDefOption("level", NA_character_),
    parallelMap.logging = getPMDefOption("logging", FALSE),
    parallelMap.show.info = getPMDefOption("show.info", TRUE),
    parallelMap.storagedir = getPMDefOption("storagedir", getwd()),
    parallelMap.status = STATUS_STOPPED,
    parallelMap.on.slave = FALSE,
    parallelMap.registered.levels = list(),
    parallelMap.suppress.local.errors = FALSE
  )
  # set defaults
  makeMulticoreCluster()
}
