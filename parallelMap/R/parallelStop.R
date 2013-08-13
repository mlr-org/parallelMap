#' Stops parallelization.
#'
#' For snowfall \code{\link[snowfall]{sfStop}} is called.
#'
#' @return Nothing.
#' @export
parallelStop = function() {
  mode = getOption("parallelMap.mode")
  if (mode == "snowfall") {
    sfStop()
  } else if (mode == "BatchJobs") {
    # clean up temp file dir of BJ
    fd = getOption("parallelMap.bj.reg.file.path")
    unlink(fd, recursive = TRUE)
  }
  options(parallelMap.mode = "local")
}
