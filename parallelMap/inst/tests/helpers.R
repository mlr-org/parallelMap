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
      expect_true(file.exists(file.path(log.dir, sprintf("%05i.log", i)))))
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

partest3 = function() {
  foo = 100  
  parallelExport("foo")  
  f = function(i) 
    i + foo
  expect_equal(parallelMap(f, 1:2), list(101, 102))
}
