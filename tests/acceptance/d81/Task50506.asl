(module tests/acceptance/d81/Task50506
  :d "Acceptance fixture for Task 50506: Purge Prohibited @pcp:d-446d Sigils Across asl-sh per C5, D81, and D77"
  :x [testCleanModulesSyntaxCheck
      testShLoggingFunctionalExecution
      testShPipelineFunctionalExecution
      testShSuiteDynamicExecution
      RunTests]
  :i [(asl-sh/log  :a log)
      (asl-sh/pipe :a pipe)])

(df testCleanModulesSyntaxCheck [] -> Bool
  :d "Verifies delimiter balance and syntax integrity of remediated asl-sh modules via bin/asl check"
  (let [(res (sys-exec "bin/asl check asl/packages/asl-sh/src/sh.asl asl/packages/asl-sh/src/core/log.asl asl/packages/asl-sh/src/core/pipe.asl asl/packages/asl-sh/tests/sh_test.asl"))
        (code (.-exitCode res))]
    (assert (= code 0) (str "asl-sh remediated modules must check cleanly: " (.-stderr res)))
    (refute (!= code 0) "asl-sh check must refute non-zero exit")
    true))

(df testShLoggingFunctionalExecution [] -> Bool
  :d "Functionally tests structured logging capabilities in cleaned log module"
  (let [(entry (log/LogEntry :level (log/info) :message "Sigil remediation verified" :timestamp 1700000000 :subsystem "asl-sh"))
        (formatted (log/formatEntry entry))]
    (assert (string-contains? formatted "[INFO ]") "Formatted log must contain severity tag")
    (refute (not (string-contains? formatted "[INFO ]")) "Must refute missing severity tag")
    (assert (string-contains? formatted "[asl-sh]") "Formatted log must contain subsystem tag")
    (assert (string-contains? formatted "Sigil remediation verified") "Formatted log must contain payload")
    true))

(df testShPipelineFunctionalExecution [] -> Bool
  :d "Functionally tests pipeline construction capabilities in cleaned pipe module"
  (let [(p (pipe/makePipeline (list)))]
    (assert (list-empty? (.-stages p)) "Empty pipeline stages must be empty")
    (refute (not (list-empty? (.-stages p))) "Must refute non-empty stages for empty pipeline")
    true))

(df testShSuiteDynamicExecution [] -> Bool
  :d "Dynamically runs sh_test suite via bin/asl CLI to verify cleaned test executes cleanly"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-sh/tests/sh_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "sh_test.asl must exit 0: " (.-stderr res)))
    (refute (!= code 0) "sh_test.asl must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "sh_test must report executed assertions")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "sh_test must not fail")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50506 acceptance tests"
  (do
    (assert (testCleanModulesSyntaxCheck) "testCleanModulesSyntaxCheck must pass")
    (assert (testShLoggingFunctionalExecution) "testShLoggingFunctionalExecution must pass")
    (assert (testShPipelineFunctionalExecution) "testShPipelineFunctionalExecution must pass")
    (assert (testShSuiteDynamicExecution) "testShSuiteDynamicExecution must pass")
    true))
