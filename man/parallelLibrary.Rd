\name{parallelLibrary}
\alias{parallelLibrary}
\title{Load packages for parallelization.}
\usage{
parallelLibrary(..., packages, master = TRUE, level = as.character(NA))
}
\arguments{
  \item{...}{[\code{character}]\cr Names of packages to
  load.}

  \item{packages}{[\code{character(1)}]\cr Names of
  packages to load.  Alternative way to pass arguments.}

  \item{master}{[\code{logical(1)}]\cr Load packages also
  on master?  Default is \code{TRUE}.}

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
Makes sure that the packages are loaded in slave process so
that they can be used in a job function which is later run
with \code{\link{parallelMap}}.

For all modes, the packages are also (potentially) loaded
on the master.
}

