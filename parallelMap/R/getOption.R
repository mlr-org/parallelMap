getPMOption = function(opt, def) {
  getOption(sprintf("parallelMap.%s",opt), def)
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

getPMOptLogDir = function() {
  log = getPMOption("logdir")
}

getPMOptLevel = function() {
  getPMOption("level")
}

getPMOptShowInfo = function() {
  getPMOption("show.info")
}

##### PM default options #####

getPMDefOptMode = function(mode) {
  if (missing(mode))
    mode = getPMDefOption("mode", MODE_LOCAL)
  checkArg(mode, choices=MODES)
  return(mode)
  
}

getPMDefOptCpus = function(cpus) {
  #NA means "do autodetect"
  if (missing(cpus)) 
    cpus = getPMDefOption("cpus", NA_integer_)
  cpus = convertInteger(cpus)
  checkArg(cpus, "integer", len=1, na.ok=TRUE)
  return(cpus)
  
}

getPMDefOptLogDir = function(logdir) {
  if (missing(logdir))
    logdir = getPMDefOption("logdir", NA_character_)
  checkArg(logdir, "character", len=1, na.ok=TRUE)
  return(logdir)
}

getPMDefOptLevel = function(level) {
  if (missing(level))
    level = getPMDefOption("level", NA_character_)
  checkArg(level, "character", len=1, na.ok=TRUE)
  return(level)
}

getPMDefOptShowInfo = function(show.info) {
  if (missing(show.info)) 
    show.info = getPMDefOption("show.info", TRUE)
  checkArg(show.info, "logical", len=1L, na.ok=FALSE) 
  return(show.info)
}

getPMDefOptAutostart = function() {
  autostart = getPMDefOption("autostart", TRUE)
  checkArg(autostart, "logical", len=1L, na.ok=FALSE) 
  return(autostart)
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


