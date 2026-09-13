(module tests/conformance/syscalls/osSyscallsTest
  :d "Syscall Builtin Conformance Suite & Boundary Edge-Case Verification"
  :x [testDirListConformance testExecCmdConformance testFileStatConformance testPathCanonicalizeConformance RunTests]
  :i [])

(df isSorted? [(lst (List String))] -> Bool
  (cond
    ((list-empty? lst) true)
    ((<= (list-length lst) 1) true)
    (:else
     (let [(h (option-or (list-head lst) ""))
           (t (option-or (list-tail lst) (list)))]
       (cond
         ((list-empty? t) true)
         (:else
          (let [(next (option-or (list-head t) ""))]
            (if (<= h next)
              (isSorted? t)
              false))))))))

(df testDirListConformance [] -> Bool
  (let [(resOk (dirList "."))
        (resErr (dirList "non_existent_directory_abcdef12345"))]
    (assert (is-ok? resOk) "dirList '.' succeeds")
    (refute (is-err? resOk) "dirList '.' must not fail")
    (mt resOk
      ((ok entries)
       (do
         (assert (> (list-length entries) 0) "dirList '.' returns non-empty list")
         (refute (list-contains? entries ".") "dirList must exclude '.'")
         (refute (list-contains? entries "..") "dirList must exclude '..'")
         (assert (isSorted? entries) "dirList returns sorted entries")
         (refute (not (isSorted? entries)) "dirList entries must be lexicographically sorted")
         true))
      ((err _) false))

    (assert (is-err? resErr) "dirList on non-existent directory returns err")
    (refute (is-ok? resErr) "dirList on non-existent directory must not succeed")
    (mt resErr
      ((err e)
       (do
         (assert (= (.-kind e) "not-found") "dirList non-existent kind is not-found")
         (refute (!= (.-kind e) "not-found") "dirList non-existent kind must be not-found")
         true))
      ((ok _) false))
    true))

(df testExecCmdConformance [] -> Bool
  (let [(rEcho (execCmd "echo hello"))
        (rExit (execCmd "sh -c 'exit 42'"))
        (rStderr (execCmd "sh -c 'echo test_err >&2'"))]
    (assert (= (.-exitCode rEcho) 0) "execCmd 'echo hello' exitCode is 0")
    (refute (!= (.-exitCode rEcho) 0) "execCmd 'echo hello' must exit 0")
    (assert (= (.-stdout rEcho) "hello\n") "execCmd 'echo hello' stdout is hello\\n")
    (refute (!= (.-stdout rEcho) "hello\n") "execCmd stdout must match hello\\n")
    (assert (= (.-stderr rEcho) "") "execCmd 'echo hello' stderr is empty")
    (refute (!= (.-stderr rEcho) "") "execCmd stderr must be empty")

    (assert (= (.-exitCode rExit) 42) "execCmd exit 42 returns exitCode 42")
    (refute (= (.-exitCode rExit) 0) "execCmd exit 42 must not return 0")

    (assert (= (.-exitCode rStderr) 0) "execCmd stderr command exits 0")
    (assert (string-contains? (.-stderr rStderr) "test_err") "stderr contains error message")
    (refute (string-contains? (.-stdout rStderr) "test_err") "stdout must not contain stderr output")
    (assert (= (.-stdout rStderr) "") "stdout is empty when only stderr was written")
    true))

(df testFileStatConformance [] -> Bool
  (let [(rFile (fileStat "asl/tools/asl.c"))
        (rDir (fileStat "asl"))
        (rNone (fileStat "non_existent_file_stat_xyz999"))]
    (assert (is-ok? rFile) "fileStat 'asl/tools/asl.c' succeeds")
    (refute (is-err? rFile) "fileStat 'asl/tools/asl.c' must not fail")
    (mt rFile
      ((ok st)
       (do
         (assert (.-isFile st) "asl.c isFile is true")
         (refute (not (.-isFile st)) "asl.c must be a regular file")
         (refute (.-isDir st) "asl.c isDir is false")
         (assert (> (.-size st) 0) "asl.c size > 0")
         (refute (<= (.-size st) 0) "asl.c size must be positive")
         (assert (> (.-mtime st) 0) "asl.c mtime > 0")
         (assert (> (.-mode st) 0) "asl.c mode > 0")
         true))
      ((err _) false))

    (assert (is-ok? rDir) "fileStat 'asl' directory succeeds")
    (refute (is-err? rDir) "fileStat directory must not fail")
    (mt rDir
      ((ok st)
       (do
         (assert (.-isDir st) "asl isDir is true")
         (refute (not (.-isDir st)) "asl must be a directory")
         (refute (.-isFile st) "asl directory isFile is false")
         true))
      ((err _) false))

    (assert (is-err? rNone) "fileStat non-existent returns err")
    (refute (is-ok? rNone) "fileStat non-existent must not succeed")
    (mt rNone
      ((err e)
       (do
         (assert (= (.-kind e) "not-found") "fileStat non-existent kind is not-found")
         (refute (!= (.-kind e) "not-found") "fileStat non-existent kind must be not-found")
         true))
      ((ok _) false))
    true))

(df testPathCanonicalizeConformance [] -> Bool
  (let [(rRoot (pathCanonicalize "."))
        (rDotDot (pathCanonicalize "asl/tools/../tools/asl.c"))
        (rDirect (pathCanonicalize "asl/tools/asl.c"))
        (rNone (pathCanonicalize "non_existent_path_canonicalize_12345"))]
    (assert (is-ok? rRoot) "pathCanonicalize '.' succeeds")
    (refute (is-err? rRoot) "pathCanonicalize '.' must not fail")
    (mt rRoot
      ((ok p)
       (do
         (assert (string-starts-with? p "/") "pathCanonicalize '.' starts with /")
         (refute (not (string-starts-with? p "/")) "pathCanonicalize '.' must be absolute")
         (refute (string-ends-with? p "/.") "pathCanonicalize must resolve trailing dot")
         true))
      ((err _) false))

    (assert (is-ok? rDotDot) "pathCanonicalize 'asl/tools/../tools/asl.c' succeeds")
    (assert (is-ok? rDirect) "pathCanonicalize 'asl/tools/asl.c' succeeds")
    (mt rDotDot
      ((ok p1)
       (mt rDirect
         ((ok p2)
          (do
            (assert (= p1 p2) "path with .. canonicalizes identically to direct path")
            (refute (!= p1 p2) "canonical paths must be equal")
            true))
         ((err _) false)))
      ((err _) false))

    (assert (is-err? rNone) "pathCanonicalize non-existent returns err")
    (refute (is-ok? rNone) "pathCanonicalize non-existent must not succeed")
    (mt rNone
      ((err e)
       (do
         (assert (= (.-kind e) "not-found") "pathCanonicalize non-existent kind is not-found")
         (refute (!= (.-kind e) "not-found") "pathCanonicalize non-existent kind must be not-found")
         true))
      ((ok _) false))
    true))

(df RunTests [] -> Bool
  (do
    (assert (testDirListConformance) "testDirListConformance passes")
    (assert (testExecCmdConformance) "testExecCmdConformance passes")
    (assert (testFileStatConformance) "testFileStatConformance passes")
    (assert (testPathCanonicalizeConformance) "testPathCanonicalizeConformance passes")
    true))
