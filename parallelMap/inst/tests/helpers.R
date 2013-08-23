# a test for normal functionality of mapping an its options
partest1 = function() {
  # normal lapply
  expect_equal(parallelMap(identity, 1), list(1))
  expect_equal(parallelMap(identity, 1:2), list(1, 2))
  y = 1:2; names(y) = y
  # simplify and names
  expect_equal(parallelMap(identity, 1:2, simplify=TRUE, use.names=TRUE), y)
  
  # more.args and mapping over 2 vectors
  f = function(x,y) x+y
  expect_equal(parallelMap(f, 1:2, more.args=list(y=1)), list(2, 3))
  expect_equal(parallelMap(f, 1:2, 2:3), list(3, 5))
  
  # with level
  expect_equal(parallelMap(identity, 1:2), list(1, 2), level="foo")
}

# test that log files are correctly generated
partest2 = function(log.dir) {
  del = function() 
    unlink(list.files(log.dir, pattern="?????.log", full.names=TRUE))
  
  # do log files exist under correct path / name?
  check.exists = function(n) 
    sapply(seq_len(n), function(i) 
      expect_true(file.exists(file.path(log.dir, sprintf("%05i.log", i)))))
  
  # do log files contain the printed output fromn the slave?
  check.contains = function(xs)  {
    Map(function(i, x) {
      s = readLines(file.path(log.dir, sprintf("%05i.log", i)))
      s = collapse(s, sep="\n")
      expect_true(grep(x, s) == 1)
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

# test that exported variables exist on slave
partest3 = function() {
  # export nothing, no change
  parallelExport()
  foo = 100  
  parallelExport("foo")  
  f = function(i) 
    i + foo
  expect_equal(parallelMap(f, 1:2), list(101, 102))
}


# test that exported libraries are loaded
partest4 = function() {
  # testhat is basically the only lib we have in suggests...
  parallelLibrary("testthat")  
  f = function(i) 
     expect_true
  res = parallelMap(f, 1:2)
  expect_true(is.list(res) && length(res) == 2 && is.function(res[[1]]))
}


