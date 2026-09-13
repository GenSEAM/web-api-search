(module tests/acceptance/d81/Task50402
  :d "Acceptance fixture for Task 50402: Remove path cheat in resolve.asl and enforce rule-8 uniformly (End-to-End)"
  :x [testMAslWithoutDocstringFailsRule8
      testMAslWithDocstringPassesCleanly
      testArbitraryPathWithoutDocstringFailsRule8
      testUnexportedFunctionWithoutDocstringPasses
      testCheckerTestDocstringsMaintained
      testRunnerExecution
      RunTests]
  :i [(../../../asl/packages/asl-checker/src/check :a c)
      (../../../asl/packages/asl-checker/src/types :a ty)])

(df testMAslWithoutDocstringFailsRule8 [] -> Bool
  :d "Verifies that m.asl with undocumented exported function fails check and produces rule-8 diagnostic"
  (let [(diags (c/checkSource "(module m :d \"d\" :x [f]) (df f [] -> Int64 42)" (map-empty) "m.asl"))]
    (refute (list-empty? diags) "m.asl without docstring must produce diagnostics")
    (assert (> (list-length diags) 0) "Diagnostic list must be non-empty")
    (let [(d1 (list-first diags))]
      (assert (= (.-code d1) "rule-8") "Diagnostic code must be rule-8")
      (refute (!= (.-code d1) "rule-8") "Diagnostic code must not be other than rule-8")
      (assert (string-contains? (.-message d1) "exported function f has no :doc") "Diagnostic message mentions rule-8 requirement")
      (refute (string-contains? (.-message d1) "rule-2") "Diagnostic must not be rule-2")
      true)))

(df testMAslWithDocstringPassesCleanly [] -> Bool
  :d "Verifies that m.asl with documented exported function passes cleanly with zero diagnostics"
  (let [(diags (c/checkSource "(module m :d \"d\" :x [f]) (df f [] -> Int64 :d \"f\" 42)" (map-empty) "m.asl"))]
    (assert (list-empty? diags) "m.asl with docstring must produce zero diagnostics")
    (refute (not (list-empty? diags)) "m.asl with docstring must not produce diagnostics")
    true))

(df testArbitraryPathWithoutDocstringFailsRule8 [] -> Bool
  :d "Verifies that arbitrary module paths enforce rule-8 uniformly without path cheats"
  (let [(diags (c/checkSource "(module arbitrary :d \"d\" :x [g]) (df g [] -> Int64 99)" (map-empty) "arbitrary.asl"))]
    (refute (list-empty? diags) "arbitrary.asl without docstring must produce diagnostics")
    (let [(d1 (list-first diags))]
      (assert (= (.-code d1) "rule-8") "arbitrary.asl diagnostic code must be rule-8")
      (refute (!= (.-code d1) "rule-8") "arbitrary.asl diagnostic code must not be other than rule-8")
      true)))

(df testUnexportedFunctionWithoutDocstringPasses [] -> Bool
  :d "Verifies that unexported functions without docstrings do not trigger rule-8"
  (let [(diags (c/checkSource "(module m :d \"d\" :x []) (df internal [] -> Int64 123)" (map-empty) "m.asl"))]
    (assert (list-empty? diags) "Unexported function does not require :d")
    (refute (not (list-empty? diags)) "Unexported function must not produce diagnostics")
    true))

(df testCheckerTestDocstringsMaintained [] -> Bool
  :d "Verifies all exported functions in checker_test.asl have docstrings and suite passes"
  (let [(res (sys-exec "bin/asl test --strict-falsify asl/packages/asl-checker/tests/checker_test.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "checker_test suite must exit 0")
    (refute (!= code 0) "checker_test suite must not fail")
    (assert (string-contains? out "assertion(s) executed") "checker_test must execute assertions")
    (refute (string-contains? out " 0 assertion(s) executed") "checker_test assertions must be non-zero")
    true))

(df testRunnerExecution [] -> Bool
  :d "Verifies Task50402_runner subprocess execution"
  (let [(res (sys-exec "bin/asl test --strict-falsify tests/acceptance/d81/Task50402_runner.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "Task50402_runner must exit 0")
    (refute (!= code 0) "Task50402_runner must not fail")
    (assert (string-contains? out "assertion(s) executed") "Task50402_runner must execute assertions")
    (refute (string-contains? out " 0 assertion(s) executed") "Task50402_runner assertions must be non-zero")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50402 end-to-end acceptance tests"
  (do
    (assert (testMAslWithoutDocstringFailsRule8) "testMAslWithoutDocstringFailsRule8 must pass")
    (assert (testMAslWithDocstringPassesCleanly) "testMAslWithDocstringPassesCleanly must pass")
    (assert (testArbitraryPathWithoutDocstringFailsRule8) "testArbitraryPathWithoutDocstringFailsRule8 must pass")
    (assert (testUnexportedFunctionWithoutDocstringPasses) "testUnexportedFunctionWithoutDocstringPasses must pass")
    (assert (testCheckerTestDocstringsMaintained) "testCheckerTestDocstringsMaintained must pass")
    (assert (testRunnerExecution) "testRunnerExecution must pass")
    true))
