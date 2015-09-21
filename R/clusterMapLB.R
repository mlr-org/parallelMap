clusterMapLB = function (cl, fun, ..., MoreArgs = NULL) {
  force(fun)
  args = list(...)
  force(MoreArgs)

  if (length(args) == 0L)
    stop("need at least one argument")
  n = viapply(args, length)
  vlen = max(n)
  ind = which(n != vlen)
  args[ind] = lapply(args[ind], rep, length = vlen)

  wrapper = function(i) do.call(fun, args = c(lapply(args, function(x) x[[i]]), MoreArgs))
  clusterApplyLB(cl, seq_len(vlen), wrapper)
}
