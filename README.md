parallelMap
===========

R package to interface some popular parallelization back-ends with a unified interface.


* Offical CRAN release site:
  http://cran.r-project.org/web/packages/parallelMap/index.html

* R Documentation in HTML:
  http://www.statistik.tu-dortmund.de/~bischl/rdocs/parallelMap/

* Run this in R to install the current GitHub version:
  ```r
  devtools::install_github("parallelMap", username="berndbischl")
  ```

* [Further installation instructions](https://github.com/tudo-r/PackagesInfo/wiki/Installation-Information)

* Travis CI: [![Build Status](https://travis-ci.org/berndbischl/parallelMap.png)](https://travis-ci.org/berndbischl/parallelMap)

Overview
========

parallelMap was written with users (like me) in mind who want a unified parallelization procedure in R that

* Works equally well in interactive operations as in developing packages where some operations should offer the possibility to be run in parallel by the client user of your package.
* Allows the client user of your developed package to completely configure the parallelization from the outside.
* Allows you to be lazy and forgetful. This entails: The same interface for every back-end and everything is easily configurable via options.
* Supports the most important parallelization modes. For me, these currently are: usage of multiple cores on a single machine, socket mode (because it also works on Windows), MPI and HPC clusters (the latter interfaced by our BatchJobs package).
* Does not make debugging annoying and tedious.


Mini Tutorial
=============

Here is a short tutorial that already contains the most important concepts and operations:

```splus
##### Example 1) #####

library(parallelMap)
parallelStartSocket(2)    # start in socket mode and create 2 processes on localhost
f = function(i) i + 5     # define our job
y = parallelMap(f, 1:2)   # like R's Map but in parallel
parallelStop()            # turn parallelization off again
```

If you want to use other modes of parallelization, simply call the appropriate initialization procedure, all of them are documented in [parallelStart](http://berndbischl.github.io/parallelMap/man/parallelStart.html). [parallelStart](http://berndbischl.github.io/parallelMap/man/parallelStart.html) is a catch-all procedure, that allows to set all possible options of the package, but for every mode a variant of [parallelStart](http://berndbischl.github.io/parallelMap/man/parallelStart.html) exists with a smaller, appropriate interface.


Exporting to Slaves: Libraries, Sources and Objects
==================================================

In many (more complex) applications you somehow need to initialize the slave processes, especially for MPI, socket and BatchJobs mode, where fresh R processes are started. This means: loading of packages, sourcing files with function and object definitions and exporting R objects to the global environment of the slaves.

parallelMap supports these operations with the following three functions

 * [parallelLibrary](http://berndbischl.github.io/parallelMap/man/parallelLibrary.html)
 * [parallelSource](http://berndbischl.github.io/parallelMap/man/parallelSource.html)
 * [parallelExport](http://berndbischl.github.io/parallelMap/man/parallelExport.html)

Let's start with loading a package on the slaves. Of course you could put a require("mypackage") into the body of f, but you can also use a [parallelLibrary](http://berndbischl.github.io/parallelMap/man/parallelLibrary.html) before calling [parallelMap](http://berndbischl.github.io/parallelMap/man/parallelMap.html).

```splus
##### Example 2) #####

library(parallelMap)
parallelStartSocket(2)
parallelLibrary("MASS")
# subsample iris, fit an LDA model and return prediction error
f = function(i) {
  n = nrow(iris)
  train = sample(n, n/2)
  test = setdiff(1:n, train)
  model = lda(Species~., data=iris[train,])
  pred = predict(model, newdata=iris[test,])
  mean(pred$class != iris[test,]$Species)
}
y = parallelMap(f, 1:2)
parallelStop()
```

And here is a further example where we export a big matrix to the slaves, then
apply a preprocessing function to it, which is defined in source file. Yeah, it is kinda
a nonsensical example but I suppose you will get the point:

```splus
##### Example 3) #####

library(parallelMap)
parallelStartSocket(2)
parallelSource("preproc.R") # contains definition of preproc()
bigmatrix = matrix(1, nrow=500, ncol=500)
parallelExport("bigmatrix")
f = function(i) {
  p = preproc(bigmatrix)
  p + i
}
y = parallelMap(f, 1:2)
parallelStop()
```


Being Lazy: Configuration and Auto-Start
========================================

On a given system, you will probably always parallelize you operations in a similar fashion. For this reason, [parallelMap](http://berndbischl.github.io/parallelMap/man/parallelMap.html) allows you to define defaults for all relevant settings through R's option mechanism in , e.g., your R profile.

Let's assume on your office PC you run some Unix-like operating system and have 4 cores at your disposal. You are also an experienced user and don't need [parallelMap](http://berndbischl.github.io/parallelMap/man/parallelMap.html)'s "chatting" on the console anymore. Simply define these lines in your R profile:


```splus
options(
  parallelMap.default.mode        = "multicore",
  parallelMap.default.cpus        = 4,
  parallelMap.default.show.info   = FALSE
)
```

This allows you to save some typing as running [parallelStart()](http://berndbischl.github.io/parallelMap/man/parallelStart.html) will now be equivalent to parallelStart(mode = "multicore", cpus=4, show.info=FALSE) so "Example 1" would become:

```splus
parallelStart()
f = function(i) i + 5
y = parallelMap(f, 1:2)
parallelStop()
```

You can later always overwrite settings be explicitly passing them to [parallelStart](http://berndbischl.github.io/parallelMap/man/parallelStart.html), so


```splus
parallelStart(cpus=2)
f = function(i) i + 5
y = parallelMap(f, 1:2)
parallelStop()
```

would use your default "multicore" mode and still disable [parallelMap](http://berndbischl.github.io/parallelMap/man/parallelMap.html)'s info messages on the console, but decrease cpu usage to 2.

Actually, we can reduce the amount of typing even further. Setting this in your R profile (let's enable messages again, so we can see more)

```splus
options(
  parallelMap.default.autostart   = TRUE,
  parallelMap.default.mode        = "multicore",
  parallelMap.default.cpus        = 4,
  parallelMap.default.show.info   = TRUE
)
```

allows you now to only write


```splus
f = function(i) i + 5
y = parallelMap(f, 1:2)
```

In the console you see what happens:

```
Auto-starting parallelization.
Starting parallelization in mode=multicore with cpus=4.
Loading required package: parallel
Doing a parallel mapping operation.
Auto-stopping parallelization.
Stopped parallelization. All cleaned up.
```

[parallelMap](http://berndbischl.github.io/parallelMap/man/parallelMap.html) auto-calls [parallelStart](http://berndbischl.github.io/parallelMap/man/parallelStart.html) in the beginning of [parallelMap](http://berndbischl.github.io/parallelMap/man/parallelMap.html) and neatly cleans everything up by calling [parallelStop](http://berndbischl.github.io/parallelMap/man/parallelStop.html) in the end.

The following options are currently available:

```splus
  parallelMap.default.autostart       = TRUE / FALSE
  parallelMap.default.mode            = "local" / "multicore" / "socket" / "mpi" / "BatchJobs"
  parallelMap.default.cpus            = <integer>
  parallelMap.default.level           = <string> or NA
  parallelMap.default.socket.hosts    = character vector of host names where to spawn in socket mode
  parallelMap.default.show.info       = TRUE / FALSE
  parallelMap.default.logging         = TRUE / FALSE
  parallelMap.default.storagedir      = <path>, must be on a shared file system for master / slaves
```

For their precise meaning please read the documentation of [parallelStart](http://berndbischl.github.io/parallelMap/man/parallelStart.html).


Package development: Tagging mapping operations with a level name
=================================================================

TO COME






