(module tests/acceptance/d81/Task50103
  :d "Acceptance fixture for Task 50103: Engine JS Runtime Dispatch & Evaluator Binding"
  :x [testDirListDispatch testExecCmdDispatch testFileStatDispatch testPathCanonicalizeDispatch RunTests]
  :i [])

(df testDirListDispatch [] -> Bool
  (let [(res (dirList "."))]
    (assert (is-ok? res) "dirList '.' returns ok")
    (refute (is-err? res) "dirList '.' must not be err")
    true))

(df testExecCmdDispatch [] -> Bool
  (let [(res (execCmd "echo hello"))]
    (assert (= (.-exitCode res) 0) "execCmd 'echo hello' exitCode is 0")
    (refute (!= (.-exitCode res) 0) "execCmd 'echo hello' must not fail")
    (assert (string-contains? (.-stdout res) "hello") "execCmd stdout contains hello")
    (refute (not (string-contains? (.-stdout res) "hello")) "execCmd stdout must contain hello")
    true))

(df testFileStatDispatch [] -> Bool
  (let [(res (fileStat "asl/tools/asl.c"))]
    (assert (is-ok? res) "fileStat 'asl/tools/asl.c' returns ok")
    (refute (is-err? res) "fileStat 'asl/tools/asl.c' must not be err")
    (mt res
      ((ok st)
       (do
         (assert (.-isFile st) "asl/tools/asl.c isFile is true")
         (refute (not (.-isFile st)) "asl/tools/asl.c must be a file")
         (assert (> (.-size st) 0) "asl/tools/asl.c size > 0")
         (refute (<= (.-size st) 0) "asl/tools/asl.c size must be positive")
         true))
      ((err _) false))))

(df testPathCanonicalizeDispatch [] -> Bool
  (let [(res (pathCanonicalize "."))]
    (assert (is-ok? res) "pathCanonicalize '.' returns ok")
    (refute (is-err? res) "pathCanonicalize '.' must not be err")
    (mt res
      ((ok p)
       (do
         (assert (string-starts-with? p "/") "pathCanonicalize '.' returns absolute path")
         (refute (not (string-starts-with? p "/")) "pathCanonicalize must return absolute path")
         true))
      ((err _) false))))

(df RunTests [] -> Bool
  (do
    (assert (testDirListDispatch) "testDirListDispatch passes")
    (assert (testExecCmdDispatch) "testExecCmdDispatch passes")
    (assert (testFileStatDispatch) "testFileStatDispatch passes")
    (assert (testPathCanonicalizeDispatch) "testPathCanonicalizeDispatch passes")
    true))
