#' Stops parallelization.
#'
#' For snowfall \code{\link[snowfall]{sfStop}} is called.
#'
#' @return Nothing.
#' @export
parallelStop = function() {
  mode = getOption("BBmisc.parallel.mode")
  if (mode == "snowfall") {
    sfStop()
  } else if (mode == "BatchJobs") {
    # clean up temp file dir of BJ
    fd = getOption("BBmisc.parallel.bj.reg.file.path")
    unlink(fd, recursive = TRUE)
  }
  options(BBmisc.parallel.mode = "local")
}
