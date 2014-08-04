getPMOption = function(opt, def) {
  getOption(sprintf("parallelMap.%s", opt), def)
}

getPMDefOption = function(opt, def) {
  getOption(sprintf("parallelMap.default.%s", opt), def)
}

getPMOptStatus = function() {
  getPMOption("status")
}

##### PM current options #####

getPMOptMode = function() {
  getPMOption("mode")
}

getPMOptCpus = function() {
  getPMOption("cpus")
}

getPMOptSocketHosts = function() {
  getPMOption("socket.hosts")
}

getPMOptLogging = function() {
  getPMOption("logging")
}

getPMOptLevel = function() {
  getPMOption("level")
}

getPMOptShowInfo = function() {
  getPMOption("show.info")
}

getPMOptStorageDir = function() {
  getPMOption("storagedir")
}

getPMOptBatchJobsResources = function() {
  getPMOption("bj.resources", list())
}

getPMOptNextMap = function() {
  getPMOption("nextmap")
}

getPMOptOnSlave = function() {
  getPMOption("on.slave")
}

##### PM default options #####

getPMDefOptMode = function(mode) {
  if (missing(mode))
    mode = getPMDefOption("mode", MODE_LOCAL)
  assertChoice(mode, MODES)
  return(mode)
}

getPMDefOptCpus = function(cpus) {
  # NA means "do autodetect"
  if (missing(cpus))
    cpus = getPMDefOption("cpus", NA_integer_)
  cpus = asInt(cpus, na.ok=TRUE, lower=1L)
  return(cpus)
}

getPMDefOptSocketHosts = function(socket.hosts) {
  if (missing(socket.hosts))
    socket.hosts = getPMDefOption("socket.hosts", NULL)
  if (!is.null(socket.hosts))
    assertCharacter(socket.hosts, min.len=1L, any.missing = FALSE)
  return(socket.hosts)
}

getPMDefOptLogging = function(logging) {
  if (missing(logging))
    logging = getPMDefOption("logging", FALSE)
  assertFlag(logging)
  return(logging)
}

getPMDefOptLevel = function(level) {
  if (missing(level))
    level = getPMDefOption("level", NA_character_)
  assertString(level, na.ok = TRUE)
  return(level)
}

getPMDefOptShowInfo = function(show.info) {
  if (missing(show.info))
    show.info = getPMDefOption("show.info", TRUE)
  assertFlag(show.info)
  return(show.info)
}

getPMDefOptStorageDir = function(storagedir) {
  if (missing(storagedir))
    storagedir = getPMDefOption("storagedir", getwd())
  assertString(storagedir)
  return(storagedir)
}

##### modes #####

isModeLocal = function() {
  getPMOptMode() == MODE_LOCAL
}

isModeMulticore = function() {
  getPMOptMode() == MODE_MULTICORE
}

isModeSocket = function() {
  getPMOptMode() == MODE_SOCKET
}

isModeMPI = function() {
  getPMOptMode() == MODE_MPI
}

isModeBatchJobs = function() {
  getPMOptMode() == MODE_BATCHJOBS
}

##### status #####

isStatusStarted = function() {
  getPMOptStatus() == STATUS_STARTED
}

isStatusStopped = function() {
  getPMOptStatus() == STATUS_STOPPED
}
