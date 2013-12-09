\name{parallelLapply}
\alias{parallelLapply}
\alias{parallelSapply}
\title{Parallel versions of apply-family functions.}
\usage{
parallelLapply(xs, fun, ..., level = NA_character_)

parallelSapply(xs, fun, ..., simplify = TRUE, use.names = TRUE,
  level = NA_character_)
}
\arguments{
  \item{xs}{[\code{vector} | \code{list}]\cr \code{fun} is
  applied to the elements of this argument.}

  \item{fun}{[\code{function}]\cr Function to map over
  \code{xs}.}

  \item{...}{[any]\cr Further arguments passed to
  \code{fun}.}

  \item{simplify}{[\code{logical(1)}]\cr See
  \code{\link{sapply}}.  Default is \code{TRUE}.}

  \item{use.names}{[\code{logical(1)}]\cr See
  \code{\link{sapply}}.  Default is \code{TRUE}.}

  \item{level}{[\code{character(1)}]\cr See
  \code{\link{parallelMap}}.}
}
\value{
For \code{parallelLapply} an unamed list, for
\code{parallelSapply} it depends on the return value of
\code{fun} and the settings of \code{simplify} and
\code{use.names}.
}
\description{
\code{parallelLapply}: A parallel \code{\link{lapply}}
version.\cr \code{parallelSapply}: A parallel
\code{\link{sapply}} version.\cr All functions are simple
wrappers for \code{\link{parallelMap}}.
}

