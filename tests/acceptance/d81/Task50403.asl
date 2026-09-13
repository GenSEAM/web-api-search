(module tests/acceptance/d81/Task50403
  :d "Acceptance fixture for Task 50403: Restore dual-polarity refutations and non-vacuous test execution across checker suites"
  :x [extractRefuteCount
      testSuiteExecution
      testAllSuitesDualPolarity
      RunTests]
  :i [])

(df extractRefuteCount [(out String)] -> Int64
  :d "Extracts executed refutation count from bin/asl test runner stdout"
  (let [(marker " refutation(s) executed")]
    (if (string-contains? out marker)
      (let [(parts (string-split out marker))
            (before (option-or (list-get parts 0) ""))
            (subParts (string-split before ", "))
            (lastPart (option-or (list-get subParts (- (list-length subParts) 1)) ""))
            (numStr (string-trim lastPart))]
        (as-i64 numStr))
      0)))

(df testSuiteExecution [(path String) (minRefutes Int64)] -> Int64
  :d "Executes a test suite, verifies non-vacuous assertions and refutations, and returns refutation count"
  (let [(res (sys-exec (str "bin/asl test " path)))
        (code (.-exitCode res))
        (out (.-stdout res))
        (refutes (extractRefuteCount out))]
    (assert (= code 0) (str path " must exit 0"))
    (refute (!= code 0) (str path " must not fail"))
    (assert (string-contains? out "assertion(s) executed") (str path " must report executed assertions"))
    (assert (string-contains? out "refutation(s) executed") (str path " must report executed refutations"))
    (refute (string-contains? out " 0 refutation(s) executed") (str path " refutations must be non-zero"))
    (refute (string-contains? out "(closure runTests)") (str path " must not leave uncalled closure"))
    (assert (>= refutes minRefutes) (str path " must meet minimum refutation threshold"))
    (refute (< refutes minRefutes) (str path " refutations must not be below threshold"))
    refutes))

(df testAllSuitesDualPolarity [] -> Bool
  :d "Verifies dual-polarity coverage across all 4 checker suites without grep on source files"
  (let [(cTypes (testSuiteExecution "asl/packages/asl-checker/tests/types_test.asl" 3))
        (cUnify (testSuiteExecution "asl/packages/asl-checker/tests/unify_test.asl" 3))
        (cResolve (testSuiteExecution "asl/packages/asl-checker/tests/resolve_test.asl" 3))
        (cChecker (testSuiteExecution "asl/packages/asl-checker/tests/checker_test.asl" 3))
        (total (+ (+ cTypes cUnify) (+ cResolve cChecker)))]
    (assert (>= cTypes 3) "types_test.asl refutations >= 3")
    (refute (< cTypes 3) "types_test.asl must have >= 3 refutations")
    (assert (>= cUnify 3) "unify_test.asl refutations >= 3")
    (refute (< cUnify 3) "unify_test.asl must have >= 3 refutations")
    (assert (>= cResolve 3) "resolve_test.asl refutations >= 3")
    (refute (< cResolve 3) "resolve_test.asl must have >= 3 refutations")
    (assert (>= cChecker 3) "checker_test.asl refutations >= 3")
    (refute (< cChecker 3) "checker_test.asl must have >= 3 refutations")
    (assert (>= total 20) "Total refutations across checker suites >= 20")
    (refute (< total 20) "Total refutations must not be less than 20")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50403 acceptance tests"
  (do
    (assert (testAllSuitesDualPolarity) "testAllSuitesDualPolarity must pass")
    true))
