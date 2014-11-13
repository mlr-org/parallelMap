checkResultsAndStopWithErrorsMessages = function(result.list) {
  if (length(result.list) > 0L) {
    inds = which(vlapply(result.list, inherits, what = "parallelMapErrorWrapper"))
    if (length(inds) > 0L)
      stopWithJobErrorMessages(inds, vcapply(result.list[inds], as.character))
  }
}

stopWithJobErrorMessages = function(inds, msgs, extra.msg = NULL) {
  n = length(inds)
  msgs = head(msgs, 10L)
  inds = head(inds, 10L)
  msgs = sprintf("%05i: %s", inds, msgs)
  extra.msg = ifelse(is.null(extra.msg), "", sprintf("\n%s\n", extra.msg))
  stopf("Errors occurred in %i slave jobs, displaying at most 10 of them:\n\n%s\n%s",
    n, collapse(msgs, sep="\n"), extra.msg)
}
