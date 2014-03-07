\name{parallelMap}
\alias{parallelMap}
\title{Maps a function over lists or vectors in parallel.}
\usage{
parallelMap(fun, ..., more.args = list(), simplify = FALSE,
  use.names = FALSE, level = as.character(NA), show.info = NA)
}
\arguments{
  \item{fun}{[\code{function}]\cr Function to map over
  \code{...}.}

  \item{...}{[any]\cr Arguments to vectorize over (list or
  vector).}

  \item{more.args}{[\code{list}]\cr A list of other
  arguments passed to \code{fun}.  Default is empty list.}

  \item{simplify}{[\code{logical(1)}]\cr Should the result
  be simplified?  See \code{\link{sapply}}.  Default is
  \code{FALSE}.}

  \item{use.names}{[\code{logical(1)}]\cr Should result be
  named by first vector if that is of class character?
  Default is \code{FALSE}.}

  \item{level}{[\code{character(1)}]\cr If a (non-missing)
  level is specified in \code{\link{parallelStart}}, this
  call is only parallelized if the level specified here
  matches.  Useful if this function is used in a package.
  Default is \code{NA}.}

  \item{show.info}{[\code{logical(1)}]\cr Verbose output on
  console?  Can be used to override setting from options /
  \code{\link{parallelStart}}.  Default is NA which means
  no overriding.}
}
\value{
Result.
}
\description{
Use the parallelization mode and the other options
specified in \code{\link{parallelStart}}.
}
\examples{
parallelStart()
parallelMap(identity, 1:2)
parallelStop()
}

