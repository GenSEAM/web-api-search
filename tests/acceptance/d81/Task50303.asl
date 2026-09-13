(module tests/acceptance/d81/Task50303
  :d "Acceptance fixture for Task50303: Anti-Tautological Gate Hardening Test Suite and Negative Bound Verification."
  :x [testGatesHardeningSuiteExecution
      testStrictFalsificationPassage
      testAdversarialFailureRefutation
      testRunTestsFalseRejection
      RunTests]
  :i [])

(df testGatesHardeningSuiteExecution [] -> Bool
  :d "Dynamically executes gates hardening suite and verifies non-vacuous assertions and dual-polarity refutations."
  (let [(res (sys-exec "bin/asl test asl/packages/asl-gates/tests/gates_hardening_test.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) (str "gates_hardening_test.asl must exit 0, stdout: " out))
    (refute (!= code 0) "Hardened gate test suite must pass cleanly")
    (assert (string-contains? out "assertion(s) executed") "Must report evaluated assertions")
    (assert (string-contains? out "refutation(s) executed and recorded cleanly") "Must report dual-polarity refutations")
    (refute (string-contains? out "0 assertion(s) executed") "Must not report zero assertions")
    (refute (string-contains? out "0 refutation(s) executed") "Must not report zero refutations")
    true))

(df testStrictFalsificationPassage [] -> Bool
  :d "Dynamically verifies that the hardening suite passes under strict falsification verification."
  (let [(res (sys-exec "bin/asl test --strict-falsify asl/packages/asl-gates/tests/gates_hardening_test.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) (str "Strict falsification execution must exit 0, stdout: " out))
    (refute (!= code 0) "Strict falsification test run must not fail")
    (assert (string-contains? out "92 assertion(s) executed") "Must report 92 assertions")
    (assert (string-contains? out "12 refutation(s) executed") "Must report 12 refutations")
    true))

(df testAdversarialFailureRefutation [] -> Bool
  :d "Negative bound: dynamically verifies that failing assertion triggers non-zero exit and explicit error report."
  (let [(res (sys-exec "bin/asl test tests/fixtures/failing_assert.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 1) "Failing assertion fixture must exit 1")
    (refute (= code 0) "Failing assertion fixture must refute exit 0")
    (assert (string-contains? out "[ASL_ASSERTION_FAILURE]") "Must emit assertion failure diagnostic")
    (assert (string-contains? out "adversarial failure") "Must output adversarial failure text")
    true))

(df testRunTestsFalseRejection [] -> Bool
  :d "Negative bound: dynamically verifies that a test suite returning false is rejected with non-zero exit."
  (let [(res (sys-exec "bin/asl test tests/fixtures/run_tests_false.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 1) "Suite returning false must exit 1")
    (refute (= code 0) "Suite returning false must refute exit 0")
    (assert (string-contains? out "ERR_TEST_RESULT_NOT_TRUE") "Must emit ERR_TEST_RESULT_NOT_TRUE diagnostic")
    true))

(df RunTests [] -> Bool
  :d "Master acceptance test runner for Task50303."
  (do
    (assert (testGatesHardeningSuiteExecution) "testGatesHardeningSuiteExecution must pass")
    (assert (testStrictFalsificationPassage) "testStrictFalsificationPassage must pass")
    (assert (testAdversarialFailureRefutation) "testAdversarialFailureRefutation must pass")
    (assert (testRunTestsFalseRejection) "testRunTestsFalseRejection must pass")
    true))

(RunTests)
