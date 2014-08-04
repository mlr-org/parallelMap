# get all log dirs under storage dir
getLogDirs = function() {
  # FIXME why would someone restrict here to 999 maps?
  list.files(getPMOptStorageDir(), pattern="parallelMap_logs_???", full.names=TRUE)
}

# delete all log dirs under storage dir
deleteAllLogDirs = function() {
  fns = getLogDirs()
  n = length(fns)
  if (n > 0L)
    showInfoMessage("Deleting %i log dirs in storage dir.", n)
}

getNextLogDir = function() {
  ld = file.path(getPMOptStorageDir(),
    sprintf("parallelMap_logs_%03i", getPMOptNextMap()))
  if (!file.exists(ld))
    dir.create(ld)
  ld
}
