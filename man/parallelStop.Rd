\name{parallelStop}
\alias{parallelStop}
\title{Stops parallelization.}
\usage{
parallelStop()
}
\value{
Nothing.
}
\description{
Sets mode to \dQuote{local}, i.e., parallelization is
turned off and all necessary stuff is cleaned up.
}
\details{
For socket and mpi mode \code{\link[parallel]{stopCluster}}
is called.
}

