showInfoMessage = function(msg, ...) {
  if (isShowInfoEnabled()) {
    messagef(msg, ...)
  }
}