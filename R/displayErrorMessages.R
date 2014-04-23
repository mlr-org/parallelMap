checkResultsAndStopWithErrorsMessages = function(result.list) {
  if (length(result.list) > 0) {
    inds = which(sapply(result.list, function(x) inherits(x, "parallelMapErrorWrapper")))
    if (length(inds) > 0) {
      stopWithJobErrorMessages(inds, sapply(result.list[inds], as.character))
    }
  }
}

stopWithJobErrorMessages = function(inds, msgs, extra.msg = NULL) {
  msgs = head(msgs, 10)
  msgs = sprintf("%05i: %s", inds, msgs)
  extra.msg = ifelse(is.null(extra.msg), "", sprintf("\n%s\n", extra.msg))
  stopf("Errors occurred in %i slave jobs, displaying at most 10 of them:\n\n%s\n%s",
    length(inds), collapse(msgs, sep="\n"), extra.msg)
}
