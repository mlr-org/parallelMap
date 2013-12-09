\name{parallelLibrary}
\alias{parallelLibrary}
\title{Load packages for parallelization.}
\usage{
parallelLibrary(..., packages, master = TRUE, level = as.character(NA))
}
\arguments{
  \item{...}{[\code{character(1)}]\cr Names of packages to
  load.}

  \item{packages}{[\code{character(1)}]\cr Names of
  packages to load.  Alternative way to pass arguments.}

  \item{master}{[\code{logical(1)}]\cr Load packages also
  on master?  If you set this to \code{FALSE}, nothing
  actually happens for modes local and multicore.  Default
  is \code{TRUE}.}

  \item{level}{[\code{character(1)}]\cr If a (non-missing)
  level is specified in \code{\link{parallelStart}}, the
  function only loads the packages if the level specified
  here matches.  See \code{\link{parallelMap}}.  Useful if
  this function is used in a package.  Default is
  \code{NA}.}
}
\value{
Nothing.
}
\description{
Makes sure in that case of socket, mpi and BatchJobs mode,
the packages are loaded in the slave processes. For all
modes, the packages are also (potentially) loaded on the
master. Note that loading the packages on the master is
(obviously) required for having them available during the
slave operation for modes local and multicore.
}

