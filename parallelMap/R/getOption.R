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

getPMOptLog = function() {
  getPMOption("log")
}

getPMOptLevel = function() {
  getPMOption("level")
}

getPMOptShowInfo = function() {
  getPMOption("show.info")
}

##### PM default options #####
#FIXME do the argument chekcks here

getPMDefOptMode = function() {
  getPMDefOption("mode", MODE_LOCAL)
}

getPMDefOptCpus = function() {
  #FIXME autodetect?
  getPMDefOption("cpus", 1L)
}

getPMDefOptLog = function() {
  getPMDefOption("log", as.character(NA))
}

getPMDefOptLevel = function() {
  getPMDefOption("level", as.character(NA))
}

getPMDefOptShowInfo = function() {
  getPMDefOption("show.info", TRUE)
}

getPMDefOptAutostart = function() {
  getPMDefOption("autostart", TRUE)
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


