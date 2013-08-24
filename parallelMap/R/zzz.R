#' @import BBmisc

# define constants
MODE_LOCAL = "local"
MODE_MULTICORE = "multicore"
MODE_SOCKET = "socket"
MODE_MPI = "mpi"
MODE_BATCHJOBS = "BatchJobs"
MODES = c(MODE_LOCAL, MODE_MULTICORE, MODE_SOCKET, MODE_MPI, MODE_BATCHJOBS)
  
STATUS_STARTED = "started"
STATUS_STOPPED = "stopped"

.onLoad = function(libname, pkgname) {
  # init all settings from defaults
  options(
    parallelMap.mode = getPMDefOptMode(),
    parallelMap.cpus = getPMDefOptCpus(),
    parallelMap.level = getPMDefOptLevel(),
    parallelMap.logging = getPMDefOptLogging(),
    parallelMap.autostart = getPMDefOptAutostart(),
    parallelMap.show.info = getPMDefOptShowInfo(),
    parallelMap.storagedir = getPMDefOptStorageDir(),
    parallelMap.status = STATUS_STOPPED,
    parallelMap.registered.levels = list()
  )
}
