#' @title Source R files for parallelization.
#'
#' @description
#' Makes sure that the files are sourced in slave process so that they can be used in a job
#' function which is later run with \code{\link{parallelMap}}.
#'
#' For all modes, the files are also (potentially) loaded on the master.
#'
#' @param ... [\code{character}]\cr
#'   File paths to sources.
#' @param files [\code{character}]\cr
#'   File paths to sources.
#'   Alternative way to pass arguments.
#' @param master [\code{logical(1)}]\cr
#'   Source files also on master for any mode?
#'   Default is \code{TRUE}.
#' @param level [\code{character(1)}]\cr
#'   If a (non-missing) level is specified in \code{\link{parallelStart}},
#'   the function only sources the files if the level specified here matches.
#'   See \code{\link{parallelMap}}.
#'   Useful if this function is used in a package.
#'   Default is \code{NA}.
#' @param show.info [\code{logical(1)}]\cr
#'   Verbose output on console?
#'   Can be used to override setting from options / \code{\link{parallelStart}}.
#'   Default is NA which means no overriding.
#' @return Nothing.
#' @export
parallelSource = function(..., files, master = TRUE, level = NA_character_, show.info = NA) {
  args = list(...)
  assertList(args, types = "character")
  if (!missing(files)) {
    assertCharacter(files, any.missing = FALSE)
    files = c(as.character(args), files)
  } else {
    files = as.character(args)
  }
  assertFlag(master)
  assertString(level, na.ok = TRUE)
  assertFlag(show.info, na.ok = TRUE)

  mode = getPMOptMode()

  # remove duplicates
  files = unique(files)

  if (length(files) > 0L) {
    if (master) {
      showInfoMessage("Sourcing files on master: %s", collapse(files))
      lapply(files, source)
    }

    # if level matches, load on slaves
    if (isParallelizationLevel(level)) {
      # only source when we have not already done on master
      if (mode %in% c(MODE_LOCAL, MODE_MULTICORE)) {
        if (master) {
          showInfoMessage("Source files are already available on the slave")
        } else {
          showInfoMessage("Sourcing files on master (to be available on slaves for this mode): %s",
            collapse(files), show.info = show.info)
          lapply(files, source)
        }
      } else if (mode %in% c(MODE_SOCKET, MODE_MPI)) {
        showInfoMessage("Sourcing files on slaves: %s", collapse(files), show.info = show.info)
        .parallelMap.srcs = files
        exportToSlavePkgParallel(".parallelMap.srcs", .parallelMap.srcs)
        errs = clusterEvalQ(cl = NULL, {
          sapply(.parallelMap.srcs, function(f) {
            r = try(source(f))
            if (inherits(r, "try-error"))
              as.character(r)
            else
              NA_character_
          }, USE.NAMES = TRUE)
        })
        # to vector, remove NA = ok, we also dont wnat to read error multiple times for multiple slaves
        errs = unlist(errs)
        errs = errs[!is.na(errs), drop = FALSE]
        errs = errs[!duplicated(names(errs))]
        if (length(errs) > 0L)
          stopf("Files could not be sourced on all slaves: %s\n%s",
            collapse(names(errs)), collapse(paste(names(errs), errs, sep = "\n"), sep = "\n"))
      } else if (isModeBatchJobs()) {
        showInfoMessage("Storing source file info for BatchJobs slave jobs: %s",
          collapse(files), show.info = show.info)
        suppressMessages({
          reg = getBatchJobsReg()
          BatchJobs::addRegistrySourceFiles(reg, files, src.now = FALSE)
        })
      }
    }
  }
  invisible(NULL)
}
