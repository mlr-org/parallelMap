<!-- NEWS.md is maintained by https://cynkra.github.io/fledge, do not edit -->

# parallelMap 1.5.1

- Removed "LazyDate" field from DESCRIPTION.
- Fixed broken URLs.


# parallelMap 1.5.0

- `parallelLapply()` does not drop list element names anymore (#58)
- `parallelStart()` gains argument `reproducible`.
  This argument ensures reproducibility across parallel workers and is set to `TRUE` by default.
  Internally, we take care to use the `"L'Ecuyer-CMRG"` RNG kind or `clusterSetRNGStream()` (depending on the parallel mode) to ensure this.
  This argument works similar to the `future.seed` argument for future-based parallelization which also ensures reproducibility across parallel processes with the standard RNG kind.

- `parallelLibrary()`: Respect custom levels when exporting packages (#67)

- `parallelLibrary()`: Allow to add packages to a batchtools library (@dagola, #70)

- Bugfix: Printing the state of an object holding the current parallelMap options (queried via `parallelGetOptions()`) did not return the object state but instead the global state of the options (#41, @mb706).


# parallelMap 1.4.0.9000

- `parallelLapply()` does not drop list element names anymore (#58)
- `parallelStart()` gains argument `reproducible`.
  This argument ensures reproducibility across parallel workers and is set to `TRUE` by default.
  Internally, we take care to use the `"L'Ecuyer-CMRG"` RNG kind or `clusterSetRNGStream()` (depending on the parallel mode) to ensure this.
  This argument works similar to the `future.seed` argument for future-based parallelization which also ensures reproducibility across parallel processes with the standard RNG kind.

- `parallelLibrary()`: Respect custom levels when exporting packages (#67)

- `parallelLibrary()`: Allow to add packages to a batchtools library (@dagola, #70)

- Bugfix: Printing the state of an object holding the current parallelMap options (queried via `parallelGetOptions()`) did not return the object state but instead the global state of the options (#41, @mb706).

# parallelMap 1.4

- Load balancing for multicore, socket and mpi can now be controlled via the flag
  "load.balancing" passed to parallelStart().
  Note that the default for multicore now defaults to disabled load balancing.
- BatchTools mode

# parallelMap 1.3

- parallelGetRegisteredLevels has new argument "flatten"
- parallelShowOptions was converted to parallelGetOptions (with a printer)

# parallelMap 1.2

- Arguments of mcmapply (mc.preschedule, ...) can now be specified via parallelStart
- We import package "parallel" now
- parallelShowRegisteredLevels was changed to parallelGetRegisteredLevels.
  The latter returns a structured object, with a printer method.

# parallelMap 1.1

- Package in general much more stable now
- parallelLibrary was improved a lot
- better / more configurable info messages on console
- BatchJobs mode: working directory for slave jobs is the current working dir on the master,
  not the storage.dir
- BatchJobs mode: errors are thrown, if jobs expire
- parallelMap/Lapply/Sapply: impute.error option
- removed autostart option for stability

## new functions

- parallelSource
- parallelExport

# parallelMap 1.0-83

- First submit to CRAN.

