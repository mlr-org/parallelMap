if (getRversion() >= "3.1.1") {
  mcmapply_fixed = mcmapply
} else {
  mcmapply_fixed = function (FUN, ..., MoreArgs = NULL, SIMPLIFY = TRUE, USE.NAMES = TRUE,
    mc.preschedule = TRUE, mc.set.seed = TRUE, mc.silent = FALSE,
    mc.cores = getOption("mc.cores", 2L), mc.cleanup = TRUE) {
    FUN <- match.fun(FUN)
    dots <- list(...)
    if (!length(dots))
      return(list())
    lens <- sapply(dots, length)
    n <- max(lens)
    if (n && min(lens) == 0L)
      stop("Zero-length inputs cannot be mixed with those of non-zero length")
    answer <- if (mc.cores == 1L) # <- only touched this line!
      .mapply(FUN, dots, MoreArgs)
    else {
      X <- if (!all(lens == n))
        lapply(dots, function(x) rep(x, length.out = n))
      else dots
      do_one <- function(indices, ...) {
        dots <- lapply(X, function(x) x[indices])
        .mapply(FUN, dots, MoreArgs)
      }
      answer <- mclapply(seq_len(n), do_one, mc.preschedule = mc.preschedule,
        mc.set.seed = mc.set.seed, mc.silent = mc.silent,
        mc.cores = mc.cores, mc.cleanup = mc.cleanup)
      do.call(c, answer)
    }
    if (USE.NAMES && length(dots)) {
      if (is.null(names1 <- names(dots[[1L]])) && is.character(dots[[1L]]))
        names(answer) <- dots[[1L]]
      else if (!is.null(names1))
        names(answer) <- names1
    }
    if (!identical(SIMPLIFY, FALSE) && length(answer))
      simplify2array(answer, higher = (SIMPLIFY == "array"))
    else answer
  }
}
