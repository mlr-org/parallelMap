parallelMap
===========

R package to interface some popular parallelization back-ends with a unified interface. 

Overview
========

parallelMap was written with users (like me) in mind who want a unified parallelization procedure in R that

* Works equally well in interactive operations as in developing packages where some operations should offer the possibility to be run in parallel by the client user of your package. 
* Allows the client user of your developed package to completely configure the parallelization from the outside. 
* Allows you to be lazy and forgetful. This entails: The same interface for every back-end and everything is easily configurable via options. 
* Supports the most important parallelization modes. For me, these currently are: usage of multiple cores on a single machine, socket mode (because it also works on Windows), MPI and HPC clusters (the latter interfaced by our BatchJobs package).
* Does not make debugging annoying and tedious. 

The complete package documentation is available here:
http://www.statistik.tu-dortmund.de/~bischl/rdocs/parallelMap/html/

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

If you want to use other modes of parallelization, simply call the appropriate initialization procedure, all of them are documented in [parallelStart](http://www.statistik.tu-dortmund.de/~bischl/rdocs/parallelMap/html/parallelStart.html). parallelStart is a catch-all procedure, that allows to set all possible options of the package, but for every mode a variant of parallelStart exists with a smaller, appropriate interface.

Now usually you need some packages loaded on the slaves. Of course you could put a require("mypackage") into the body of f, but you can also use a parallelLibary before calling parallelMap.

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

Being Lazy: Configuration and Auto-Start
========================================

On a given system, you will probably always parallelize you operations in a similar fashion. For this reason, parallelMap allows you to define defaults for all relevant settings through R's option mechanism in , e.g., your R profile.  

Let's assume on your office PC you run some Unix-like operating system and have 4 cores at your disposal. You are also an experienced user and don't need parallelMap's "chatting" on the console anymore. Simply define these lines in your R profile:


```splus
options(
  parallelMap.default.mode        = "multicore",
  parallelMap.default.cpus        = 4,
  parallelMap.default.show.info   = FALSE
)
```

This allows you to save some typing as running parallelStart() will now be equivalent to parallelStart(mode = "multicore", cpus=4, show.info=FALSE) so "Example 1" would become:

```splus
parallelStart()  
f = function(i) i + 5 
y = parallelMap(f, 1:2)
parallelStop()         
```

You can later always overwrite settings be explicitly passing them to parallelStart, so 


```splus
parallelStart(cpus=2)  
f = function(i) i + 5 
y = parallelMap(f, 1:2)
parallelStop()         
```

would use your default "multicore" mode and still disable parallelMap's info messages on the console, but decrease cpu usage to 2. 

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

parallelMap auto-calls parallelStart in the beginning of parallelMap and neatly cleans everything up by calling parallelStop in the end. 

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

For their precise meaning please read the documentation of parallelStart.


Package development: Tagging mapping operations with a level name
=================================================================

TO COME






