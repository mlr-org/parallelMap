\name{parallelExport}
\alias{parallelExport}
\title{Export R objects for parallelization.}
\usage{
parallelExport(..., objnames, level = as.character(NA))
}
\arguments{
  \item{...}{[\code{character}]\cr Names of objects to
  export.}

  \item{objnames}{[\code{character(1)}]\cr Names of objects
  to export.  Alternative way to pass arguments.}

  \item{level}{[\code{character(1)}]\cr If a (non-missing)
  level is specified in \code{\link{parallelStart}}, the
  function only exports if the level specified here
  matches.  See \code{\link{parallelMap}}.  Useful if this
  function is used in a package.  Default is \code{NA}.}
}
\value{
Nothing.
}
\description{
Makes sure that the objects are exported to slave process
so that they can be used in a job function which is later
run with \code{\link{parallelMap}}.
}

