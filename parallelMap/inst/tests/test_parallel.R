context("parallel")

partest1 = function() {
  expect_equal(parallelMap(identity, 1), list(1))
  expect_equal(parallelMap(identity, 1:2), list(1, 2))
  y = 1:2; names(y) = y
  expect_equal(parallelMap(identity, 1:2, simplify=TRUE, use.names=TRUE), y)
  
  f = function(x,y) x+y
  expect_equal(parallelMap(f, 1:2, more.args=list(y=1)), list(2, 3))
  expect_equal(parallelMap(f, 1:2, 2:3), list(3, 5))
  
  expect_equal(parallelMap(identity, 1:2), list(1, 2), level="foo")
}

partest2 = function(log.dir) {
  del = function() 
    sapply(list.files(log.dir, full.names=TRUE), unlink)
  check.exists = function(n) 
    sapply(seq_len(n), function(i) 
      expect_true(file.exists(file.path(log.dir, sprintf("%03i.log", i)))))
  check.contains = function(xs)  {
    Map(function(i, x) {
      s = readLines(file.path(log.dir, sprintf("%03i.log", i)))
      s = collapse(s, sep="\n")
      expect_true(grep(x, s) == 1)
      print(grep(x,s))
    }, seq_along(xs), xs)
  }
  
  del()
  parallelMap(cat, c("xxx", "yyy"))
  check.exists(2)
  check.contains(c("xxx", "yyy"))

  del()
  parallelMap(print, c("xxx", "yyy"))
  check.exists(2)
  check.contains(c("xxx", "yyy"))

  # FIXME: for some reason this fails only in test?
  #del()
  #parallelMap(message, c("xxx", "yyy"))
  #check.exists(2)
  #check.contains(c("xxx", "yyy"))

  del()
  parallelMap(warning, c("xxx", "yyy"))
  check.exists(2)
  check.contains(c("xxx", "yyy"))
}

partest3 = function() {
  f = function(i) 
    i + parallelGetExported("foo")
  foo = 100  
  parallelExport("foo")  
  expect_equal(parallelMap(f, 1:2), list(101, 102))
}

test_that("parallel local", {
  parallelStart(mode="local")
  parallelStart(mode="local", cpus=1)
  expect_error(parallelStart(mode="local", cpus=2))
  parallelStart(mode="local", level="foo")
  expect_error(parallelStart(mode="local", log=tempdir()))
  partest1()
  partest3()
  parallelStop()
})

if (isExpensiveExampleOk()) {
  test_that("parallel multicore", {
    parallelStart(mode="multicore", cpus=2)
    partest1()
    parallelStop()
    
    expect_error(parallelStart(mode="multicore", log="xxx"))    

    parallelStart(mode="multicore", log=tempdir())
    partest2(tempdir())
    parallelStop()
    
    # check error
    # FIXME this does not work as parallel/multicore only generates a 
    # warning not an error....
    #parallelStart(mode="multicore", cpus=2)
    #f = function(i) stop("fooo")
    #expect_error(suppressWarnings(parallelMap(f, 1:3)), "fooo")
    #parallelStop()    
  })
  
  test_that("parallel snowfall", {
    parallelStart(mode="snowfall", cpus=2)
    partest1()
    parallelStop()

    parallelStart(mode="snowfall", cpus=2, type="MPI")
    partest1()
    parallelStop()
    
    parallelStart(mode="snowfall", cpus=2, log=tempdir())
    partest2(tempdir())
    parallelStop()
    
    parallelStart(mode="snowfall", cpus=2)
    partest3()
    parallelStop()

    # check error
    parallelStart(mode="snowfall", cpus=2)
    f = function(i) stop("fooo")
    expect_error(suppressWarnings(parallelMap(f, 1:3)), "fooo")
    parallelStop()    
    
  })
}  

