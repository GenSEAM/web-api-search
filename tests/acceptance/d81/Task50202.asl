(module tests/acceptance/d81/Task50202
  :d "Acceptance fixture for Task50202: Pure ASL batch evaluator engine implementation."
  :x [testBatchTestSuite testEchoBatchExecution testUnknownOpRejectionContract testSequentialFailFast testBatchModuleIntegrity RunTests]
  :i [])

(df testBatchTestSuite [] -> Bool
  (let [(res (sys-exec "bin/asl test --strict-falsify asl/packages/asl-cli/tests/batch_test.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "batch_test.asl must pass cleanly")
    (refute (!= code 0) "batch_test.asl must not fail")
    (assert (string-contains? out "assertion(s) executed") "batch_test.asl ran assertions")
    (refute (string-contains? out "0 assertion(s) executed") "batch_test.asl is non-vacuous")
    true))

(df testEchoBatchExecution [] -> Bool
  (let [(res (sys-exec "bin/asl rpc '(:batch (:echo :message \"hello pure asl\"))'"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "rpc echo batch command exits 0")
    (refute (!= code 0) "rpc echo batch must not fail")
    (assert (string-contains? out ":batch-res") "envelope contains :batch-res")
    (assert (string-contains? out ":status \"completed\"") "echo batch marked completed")
    (assert (string-contains? out ":op \"echo\"") "contains echo operation")
    (assert (string-contains? out "hello pure asl") "echoes payload text")
    (refute (string-contains? out ":ERR_") "no error code in echo batch")
    true))

(df testUnknownOpRejectionContract [] -> Bool
  (let [(res (sys-exec "bin/asl rpc '(:batch (:unknownSubsystemOp :param 99))'"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "rpc unknown op exits 0 with structured envelope")
    (refute (!= code 0) "rpc unknown op must exit 0")
    (assert (string-contains? out ":batch-res") "envelope contains :batch-res")
    (assert (string-contains? out ":status \"rejected\"") "step rejected")
    (assert (string-contains? out ":error-code \":ERR_UNIMPLEMENTED\"") "error code matches ADR-0081")
    (assert (string-contains? out "Operation not implemented") "rejection message present")
    (refute (string-contains? out ":status \"completed\"") "batch must not be completed")
    true))

(df testSequentialFailFast [] -> Bool
  (let [(res (sys-exec "bin/asl rpc '(:batch :seq true (:fakeOp1) (:echo :message \"never-run\"))'"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "sequential batch exits 0 with envelope")
    (refute (!= code 0) "sequential batch must exit 0")
    (assert (string-contains? out ":batch-res") "envelope contains :batch-res")
    (assert (string-contains? out ":status \"aborted\"") "subsequent step aborted")
    (assert (string-contains? out "prior step failed") "prior failure reason present")
    (assert (string-contains? out ":sequenced true") "sequenced mode verified")
    (refute (string-contains? out ":op \"echo\" :status \"ok\"") "second step must not execute")
    true))

(df testBatchModuleIntegrity [] -> Bool
  (let [(chkRes (sys-exec "bin/asl check asl/packages/asl-cli/src/batch.asl"))
        (gateRes (sys-exec "bin/asl gate asl/packages/asl-cli/src/batch.asl"))]
    (assert (= (.-exitCode chkRes) 0) "batch.asl delimiter balance and syntax valid")
    (refute (!= (.-exitCode chkRes) 0) "batch.asl check must exit 0")
    (assert (= (.-exitCode gateRes) 0) "batch.asl passes monorepo gate verification")
    (refute (!= (.-exitCode gateRes) 0) "batch.asl gate must exit 0")
    true))

(df RunTests [] -> Bool
  (do
    (assert (testBatchTestSuite) "testBatchTestSuite passes")
    (assert (testEchoBatchExecution) "testEchoBatchExecution passes")
    (assert (testUnknownOpRejectionContract) "testUnknownOpRejectionContract passes")
    (assert (testSequentialFailFast) "testSequentialFailFast passes")
    (assert (testBatchModuleIntegrity) "testBatchModuleIntegrity passes")
    true))
