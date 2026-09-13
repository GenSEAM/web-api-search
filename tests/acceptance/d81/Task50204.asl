(module tests/acceptance/d81/Task50204
  :d "Acceptance fixture for Task50204: CLI conformance test suite and subcommand regression hardening."
  :x [testCliTestSuiteRegression testCliHyphenSuiteRegression testSubcommandRegressions testMultiStepStatusAggregation RunTests]
  :i [])

(df testCliTestSuiteRegression [] -> Bool
  (let [(res (sys-exec "bin/asl test --strict-falsify asl/packages/asl-cli/tests/cli_test.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "cli_test.asl must pass cleanly")
    (refute (!= code 0) "cli_test.asl must not fail")
    (assert (string-contains? out "assertion(s) executed") "cli_test.asl ran assertions")
    (refute (string-contains? out "0 assertion(s) executed") "cli_test.asl is non-vacuous")
    true))

(df testCliHyphenSuiteRegression [] -> Bool
  (let [(res (sys-exec "bin/asl test --strict-falsify asl/packages/asl-cli/tests/cli-test.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "cli-test.asl must pass cleanly")
    (refute (!= code 0) "cli-test.asl must not fail")
    (assert (string-contains? out "assertion(s) executed") "cli-test.asl ran assertions")
    (refute (string-contains? out "0 assertion(s) executed") "cli-test.asl is non-vacuous")
    true))

(df testSubcommandRegressions [] -> Bool
  (do
    (let [(vRes (sys-exec "bin/asl version"))]
      (assert (= (.-exitCode vRes) 0) "bin/asl version exits 0")
      (refute (!= (.-exitCode vRes) 0) "bin/asl version must not fail")
      (assert (string-contains? (.-stdout vRes) "asl") "version string valid")
      (refute (string-contains? (.-stdout vRes) "error") "version has no error"))
    (let [(hRes (sys-exec "bin/asl help"))]
      (assert (= (.-exitCode hRes) 0) "bin/asl help exits 0")
      (refute (!= (.-exitCode hRes) 0) "bin/asl help must not fail")
      (assert (string-contains? (.-stdout hRes) "Usage: asl") "help contains usage")
      (refute (string-contains? (.-stdout hRes) "error") "help has no error"))
    (let [(cRes (sys-exec "bin/asl check asl/packages/asl-cli/src/cli.asl"))]
      (assert (= (.-exitCode cRes) 0) "bin/asl check cli.asl exits 0")
      (refute (!= (.-exitCode cRes) 0) "bin/asl check must not fail")
      (assert (string-contains? (.-stdout cRes) "verified cleanly") "syntax check passed"))
    (let [(eRes (sys-exec "bin/asl eval '(+ 21 21)'"))]
      (assert (= (.-exitCode eRes) 0) "bin/asl eval exits 0")
      (refute (!= (.-exitCode eRes) 0) "bin/asl eval must not fail")
      (assert (string-contains? (.-stdout eRes) "42") "eval evaluates (+ 21 21) = 42"))
    true))

(df testMultiStepStatusAggregation [] -> Bool
  (do
    (let [(allPassRes (sys-exec "bin/asl rpc '(:batch (:echo :message \"a\") (:echo :message \"b\"))'"))]
      (assert (= (.-exitCode allPassRes) 0) "all pass exits 0")
      (let [(out (.-stdout allPassRes))]
        (assert (string-contains? out ":status \"completed\"") "all pass completed")
        (assert (string-contains? out ":itemsCount 2") "itemsCount 2")
        (refute (string-contains? out ":failed-count") "no failed count on success")))
    (let [(partFailRes (sys-exec "bin/asl rpc '(:batch (:echo :message \"ok\") (:unimplementedOp))'"))]
      (assert (= (.-exitCode partFailRes) 0) "part fail exits 0")
      (let [(out (.-stdout partFailRes))]
        (assert (string-contains? out ":status \"completed-with-errors\"") "partial failure completed-with-errors")
        (assert (string-contains? out ":failed-count 1") "failed-count 1")
        (refute (string-contains? out ":status \"completed\" :itemsCount 2") "not fully completed")))
    (let [(allFailRes (sys-exec "bin/asl rpc '(:batch (:unimplementedOp1) (:unimplementedOp2))'"))]
      (assert (= (.-exitCode allFailRes) 0) "all fail exits 0")
      (let [(out (.-stdout allFailRes))]
        (assert (string-contains? out ":status \"failed\"") "all fail marked failed")
        (assert (string-contains? out ":failed-count 2") "failed-count 2")
        (refute (string-contains? out ":status \"completed\"") "not completed")))
    true))

(df RunTests [] -> Bool
  (do
    (assert (testCliTestSuiteRegression) "testCliTestSuiteRegression passed")
    (assert (testCliHyphenSuiteRegression) "testCliHyphenSuiteRegression passed")
    (assert (testSubcommandRegressions) "testSubcommandRegressions passed")
    (assert (testMultiStepStatusAggregation) "testMultiStepStatusAggregation passed")
    true))
