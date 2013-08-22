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
  options(parallelMap.mode = getPMDefOptMode())
  # FIXME this fuzcks up autodetect
  options(parallelMap.cpus = getPMDefOptCpus())
  options(parallelMap.level = getPMDefOptLevel())
  options(parallelMap.log = getPMDefOptLog())
  options(parallelMap.autostart = getPMDefOptAutostart())
  options(parallelMap.show.info = getPMDefOptShowInfo())
  options(parallelMap.status = STATUS_STOPPED)
}
