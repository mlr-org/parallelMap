library(BBmisc)
library(testthat)

doJobs = function(type, mode) {
  job = switch(type,
    short = function(x) {
      x^2
    }, 
    long = function(x) {
      Sys.sleep(5)
      x^2
    }, 
    export = function(x) {
      #i = parallelGetExported("i")
      i * x^2
    },
    lib = function(x) {
      m = randomForest(Species~., data=iris, ntree=1)
      x^2
    }
  )
  xs = 1:2
  if (type == "export") {
    i = 1
    #parallelExport("i")
  }else if (type == "lib") {
    parallelLibrary("randomForest")
  }
  st = system.time({
  ys = parallelMap(job, xs, simplify = TRUE)
  })
  #print(ys)
  expect_equal(ys, c(1, 4))
  messagef("type=%s; mode=%s; time: %2f", type, mode, st[3])
}

doTest = function(type, mode, cpus) {
  parallelStart(mode = mode, cpus = cpus)
  doJobs(type, mode)
  parallelStop()
}

doTest("short", "local")
doTest("short", "multicore", 2)
doTest("short", "snowfall", 2)

doTest("long", "local")
doTest("long", "multicore", 2)
doTest("long", "snowfall", 2)

doTest("export", "local")
doTest("export", "multicore", 2)
doTest("export", "snowfall", 2)

doTest("lib", "local")
doTest("lib", "multicore", 2)
doTest("lib", "snowfall", 2)

