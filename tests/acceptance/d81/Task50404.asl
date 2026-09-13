(module tests/acceptance/d81/Task50404
  :d "Acceptance fixture for Task 50404: Full Phase 504 End-to-End Certification"
  :x [testTask50401Certified
      testTask50402Certified
      testTask50403Certified
      testPhase504Registration
      testDualPolarityTotalCounts
      RunTests]
  :i [])

(df testTask50401Certified [] -> Bool
  :d "Verifies that Task50401 acceptance fixture executes and passes cleanly"
  (let [(res (sys-exec "bin/asl test --strict-falsify tests/acceptance/d81/Task50401.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "Task50401 acceptance test must pass with exit code 0")
    (refute (!= code 0) "Task50401 acceptance test must not fail")
    (assert (string-contains? out "assertion(s) executed") "Task50401 must execute assertions")
    (assert (string-contains? out "refutation(s) executed") "Task50401 must execute refutations")
    (refute (string-contains? out " 0 assertion(s) executed") "Task50401 assertions must be non-zero")
    true))

(df testTask50402Certified [] -> Bool
  :d "Verifies that Task50402 acceptance fixture executes and passes cleanly"
  (let [(res (sys-exec "bin/asl test --strict-falsify tests/acceptance/d81/Task50402.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "Task50402 acceptance test must pass with exit code 0")
    (refute (!= code 0) "Task50402 acceptance test must not fail")
    (assert (string-contains? out "assertion(s) executed") "Task50402 must execute assertions")
    (assert (string-contains? out "refutation(s) executed") "Task50402 must execute refutations")
    (refute (string-contains? out " 0 assertion(s) executed") "Task50402 assertions must be non-zero")
    true))

(df testTask50403Certified [] -> Bool
  :d "Verifies that Task50403 acceptance fixture executes and passes cleanly"
  (let [(res (sys-exec "bin/asl test --strict-falsify tests/acceptance/d81/Task50403.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "Task50403 acceptance test must pass with exit code 0")
    (refute (!= code 0) "Task50403 acceptance test must not fail")
    (assert (string-contains? out "assertion(s) executed") "Task50403 must execute assertions")
    (assert (string-contains? out "refutation(s) executed") "Task50403 must execute refutations")
    (refute (string-contains? out " 0 assertion(s) executed") "Task50403 assertions must be non-zero")
    true))

(df testPhase504Registration [] -> Bool
  :d "Verifies that all Phase 504 tasks are registered in sovereign memory"
  (let [(res (sys-exec "sh -c 'cat .asl/mem/tasks/Phase504CheckerFixes.asn'"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "Task registration file must be readable")
    (refute (!= code 0) "Task registration read must not fail")
    (assert (string-contains? out "Phase504CheckerFixes") "Phase collection declared")
    (assert (string-contains? out ":id \"Task50401\"") "Task50401 registered")
    (assert (string-contains? out ":id \"Task50402\"") "Task50402 registered")
    (assert (string-contains? out ":id \"Task50403\"") "Task50403 registered")
    (assert (string-contains? out ":id \"Task50404\"") "Task50404 registered")
    (refute (string-contains? out "Task50499") "Phantom task must not exist")
    true))

(df getRefuteCountInFile [(path String)] -> Int64
  :d "Parses executed refutation count from bin/asl test output"
  (let [(cmd (str "bin/asl test " path))
        (res (sys-exec cmd))
        (out (.-stdout res))
        (marker " refutation(s) executed")]
    (if (string-contains? out marker)
      (let [(parts (string-split out marker))
            (before (option-or (list-get parts 0) ""))
            (subParts (string-split before ", "))
            (lastPart (option-or (list-get subParts (- (list-length subParts) 1)) ""))
            (numStr (string-trim lastPart))]
        (as-i64 numStr))
      0)))

(df testDualPolarityTotalCounts [] -> Bool
  :d "Verifies dual-polarity coverage and non-vacuous execution across all checker test suites"
  (let [(cTypes (getRefuteCountInFile "asl/packages/asl-checker/tests/types_test.asl"))
        (cUnify (getRefuteCountInFile "asl/packages/asl-checker/tests/unify_test.asl"))
        (cResolve (getRefuteCountInFile "asl/packages/asl-checker/tests/resolve_test.asl"))
        (cChecker (getRefuteCountInFile "asl/packages/asl-checker/tests/checker_test.asl"))
        (total (+ (+ cTypes cUnify) (+ cResolve cChecker)))]
    (assert (>= cTypes 3) "types_test.asl refutations >= 3")
    (refute (< cTypes 3) "types_test.asl must have >= 3 refutations")
    (assert (>= cUnify 3) "unify_test.asl refutations >= 3")
    (refute (< cUnify 3) "unify_test.asl must have >= 3 refutations")
    (assert (>= cResolve 3) "resolve_test.asl refutations >= 3")
    (refute (< cResolve 3) "resolve_test.asl must have >= 3 refutations")
    (assert (>= cChecker 3) "checker_test.asl refutations >= 3")
    (refute (< cChecker 3) "checker_test.asl must have >= 3 refutations")
    (assert (>= total 20) "Total checker refutations >= 20")
    (refute (< total 20) "Total checker refutations must not be less than 20")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50404 certification tests"
  (do
    (assert (testTask50401Certified) "testTask50401Certified must pass")
    (assert (testTask50402Certified) "testTask50402Certified must pass")
    (assert (testTask50403Certified) "testTask50403Certified must pass")
    (assert (testPhase504Registration) "testPhase504Registration must pass")
    (assert (testDualPolarityTotalCounts) "testDualPolarityTotalCounts must pass")
    true))
