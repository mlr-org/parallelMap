\name{parallelSource}
\alias{parallelSource}
\title{Source R files for parallelization.}
\usage{
parallelSource(..., files, master = TRUE, level = as.character(NA))
}
\arguments{
  \item{...}{[\code{character(1)}]\cr File paths to
  sources.}

  \item{files}{[\code{character}]\cr File paths to sources.
  Alternative way to pass arguments.}

  \item{master}{[\code{logical(1)}]\cr Source files also on
  master?  Default is \code{TRUE}.}

  \item{level}{[\code{character(1)}]\cr If a (non-missing)
  level is specified in \code{\link{parallelStart}}, the
  function only sources the files if the level specified
  here matches.  See \code{\link{parallelMap}}.  Useful if
  this function is used in a package.  Default is
  \code{NA}.}
}
\value{
Nothing.
}
\description{
Makes sure that the files are sourced in slave process so
that they can be used in a job function which is later run
with \code{\link{parallelMap}}.

For all modes, the files are also (potentially) loaded on
the master.
}

