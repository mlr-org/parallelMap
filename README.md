parallelMap
===========

R package to interface some popular parallelization back-ends with a unified interface. 

Overview
========

parallelMap was written with users (like me) in mind who want a unified parallelization procedure in R that

* Works equally well in interactive operations as in developing packages where some operations should offer the possibility to be run in parallel by the client user of your package. 

* Allows the client user of your developed package to completely configure the paralleization from the outside. 

* Allows you to be lazy and forgetful. This entails: The same interface for every back-end and everything is easiliy configurable via options. 

* Supports the most important parallelization modi. For me, these currently are usage of muliple cores on a single machine, socket mode (because it also works on Windows), MPI and HPC clusters (the latter interfaced by our BatchJobs package).

* Does not make debugging annoying and tedious. 


Mini Tutorial
=============

Here is a short tutorial that already contains the most important concepts and operations: 

```
##### Example 1) #####

parallelStartSocket(2)    # start in socket mode and create 2 processes on localhost
f = function(i) i + 5     # define our job
y = parallelMap(f, 1:2)   # like R's Map but in parallel
parallelStop()            # turn parallelization off again
```

If you want to use other modes of parallelization, simply call the appropriate initialization procedure, all of them are documented in parallelStart. parallelStart is a catch-all procedure, that allows to set all available.....

Now usually you need some packages loaded on the slaves. Of course you could put a require("mypackage") into the body of f, but you can also use a parallelLibary before calling parallelMap in the above example. 
And in some cases it might be more efficient to directly export some large data to the global environment of the slave than passing it directly to the job function by using the more.args argument of parallelMap.
(Whether the former acfually IS more efficient, depends on the paralleliazation mode.)
Such a data export can be done with the function parallelExport. 

```
##### Example 2) #####

parallelStartSocket(2)    
parallelLibrary("foo1", "foo2") 
mydata = iris
mytarget = "Species"
parallelExport("mydara", "mytarget")
f = function(i) {
  n = nrow(mydata)
  train = 
  form = reformulate(target, ".")
  model = lda(form, data=mydata)
}

y = parallelMap(f, 1:2)   
parallelStop()            
```

Being Lazy: Configuration and Auto-Start
========================================

On a given system, you will probably always parallelize you operations in a similar fashion. For this reason, parallelMap allows you to define defaults for all relevant settings through R's option mechanism in , e.g., your R profile.  

Let's assume on your office PC you run some Unix-like operating system and have 4 cores at your disposal. You are also an experienced user and don't need parallelMap's "chatting" on the console anymore. Simply define these lines in your R profile:


```
options(
  parallelMap.default.mode        = "multicore",
  parallelMap.default.cpus        = 4,
  parallelMap.default.show.info   = FALSE
)
```

This allows you to save some typing as running parallelStart() will now be equivalent to parallelStart(mode = "multicore", cpus=4, show.info=FALSE) so "Example 1" would become:

```
parallelStart()  
f = function(i) i + 5 
y = parallelMap(f, 1:2)
parallelStop()         
```

You can later always overwrite settings be explicitly passing them to parallelStart, so 


```
parallelStart(cpus=2)  
f = function(i) i + 5 
y = parallelMap(f, 1:2)
parallelStop()         
```

would use your default "multicore" mode and still disable parallelMap's info messages on the console, but decrease cpu usage to 2. 

Actually, we can reduce the amount of typing even further. Setting this in your R profile (let's enable messages again, so we can see more)

```
options(
  parallelMap.default.autostart   = TRUE,
  parallelMap.default.mode        = "multicore",
  parallelMap.default.cpus        = 4,
  parallelMap.default.show.info   = TRUE
)
```

allows you now to only write 


```
f = function(i) i + 5 
y = parallelMap(f, 1:2)
```

In the console you see what happens:

parallelMap auto-calls parallelStart in the bginning of parallelMap and neatly cleans everything up by calling parallelStop in the end. 

The following options are currently available:

```
  parallelMap.default.autostart       = TRUE / FALSE
  parallelMap.default.mode            = "local" / "multicore" / "socket" / "MPI" / "BatchJobs"
  parallelMap.default.cpus            = <integer>
  parallelMap.default.level           = TRUE / FALSE
  parallelMap.default.socket.hosts    = TRUE / FALSE
  parallelMap.default.show.info       = TRUE / FALSE
  parallelMap.default.logging         = TRUE / FALSE
  parallelMap.default.storagedir      = <path>
```

For their precise meaning please read parallelStart.

The complete package documentation is available here. 





