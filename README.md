parallelMap
===========

R package to interface some popular parallelization back-ends with a unified interface. 

Overview
========

parallelMap was written to with users (like me) in mind who want a unified parallelization procedure in R that

* Works equally well in interactive operations as while developing packages where some operations should offer the possibility to be run in parallel by the client user of your package. 

* Allows the client user of your developed package to completely configure the paralleization from the outside. 

* Allows you to be lazy and forgetful. This entails: The same interface for every back-end and everything is easiliy configurable via options. 

* Supports the most important parallelization modi. For me, these currently are usage of muliple cores on a single machine, socket mode (because it also works on Windows), MPI and HPC clusters (interfaced by our BatchJobs package).

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

If you want to use other modes of paralleliaztion, simply call the appropriate initialization procedure, all of them are documented --->>> here.

Now usually you need some packages loaded on the slaves. Of course you could put a require("mypackage") into the body of f, but you can also use a parallelLibary before calling parallelMap in the above example. 


```
##### Example 2) #####

parallelStartSocket(2)    
# load packages foo1 and foo2 on slaves and master
# we assume both are needed to execute the body of f
parallelLibrary("foo1", "foo2") 
f = function(i) {...}
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





