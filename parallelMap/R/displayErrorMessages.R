checkForAndDisplayErrors = function(result.list) {
  inds.err = sapply(res, is.error)
  if (any(inds.err)) {
    j = res[inds.err]
    displayErrorMessages(sapply(res[inds.err], as.character))
  }
}


displayErrorMessages() = function(msgs) {
    "Errors occurred in %i slave jobs"
    stop(collapse(c("\n", sapply(, as.character), sep="\n")))
  
}