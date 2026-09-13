(module tests/acceptance/d81/Task50205
  :d "Acceptance fixture for Task50205: Full Monorepo Supervisor Verification Gate and Task Registry."
  :x [testTaskRegistration testPhase502TaskFixtures testCliAndBatchIntegration RunTests]
  :i [])

(df testTaskRegistration [] -> Bool
  (let [(res (sys-exec "sh -c 'cat .asl/mem/tasks/Phase502PureAslCliAndRpcDispatcher.asn'"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "task registration file readable")
    (refute (!= code 0) "cat Phase502 task file must exit 0")
    (assert (string-contains? out "Phase502PureAslCliAndRpcDispatcher") "phase collection declared")
    (assert (string-contains? out ":id \"Task50201\"") "Task50201 registered")
    (assert (string-contains? out ":id \"Task50202\"") "Task50202 registered")
    (assert (string-contains? out ":id \"Task50203\"") "Task50203 registered")
    (assert (string-contains? out ":id \"Task50204\"") "Task50204 registered")
    (assert (string-contains? out ":id \"Task50205\"") "Task50205 registered")
    (refute (string-contains? out "Task50299") "phantom tasks not present")
    true))

(df verifyTaskFixture [(taskFile String)] -> Bool
  (let [(cmd (str "bin/asl test --strict-falsify " taskFile))
        (res (sys-exec cmd))
        (code (.-exitCode res))]
    (assert (= code 0) (str "Task fixture " taskFile " passed cleanly"))
    (refute (!= code 0) (str "Task fixture " taskFile " must not fail"))
    (assert (string-contains? (.-stdout res) "assertion(s) executed") (str taskFile " executed assertions"))
    (refute (string-contains? (.-stdout res) "0 assertion(s) executed") (str taskFile " non-vacuous"))
    true))

(df testPhase502TaskFixtures [] -> Bool
  (do
    (assert (verifyTaskFixture "tests/acceptance/d81/Task50201.asl") "Task50201 verified")
    (assert (verifyTaskFixture "tests/acceptance/d81/Task50202.asl") "Task50202 verified")
    (assert (verifyTaskFixture "tests/acceptance/d81/Task50203.asl") "Task50203 verified")
    (assert (verifyTaskFixture "tests/acceptance/d81/Task50204.asl") "Task50204 verified")
    true))

(df testCliAndBatchIntegration [] -> Bool
  (do
    (let [(res1 (sys-exec "bin/asl rpc '(:batch (:echo :message \"supervisor-cert\") (:where :symbol \"evalBatch\"))'"))]
      (assert (= (.-exitCode res1) 0) "compound rpc exits 0")
      (let [(out1 (.-stdout res1))]
        (assert (string-contains? out1 ":batch-res") "envelope has :batch-res")
        (assert (string-contains? out1 ":itemsCount 2") "two steps evaluated")
        (assert (string-contains? out1 "supervisor-cert") "echo executed")
        (assert (string-contains? out1 ":op \"where\"") "where executed")
        (refute (string-contains? out1 ":status \"failed\"") "not failed")))
    (let [(res2 (sys-exec "bin/asl check asl/packages/asl-cli/src/cli.asl"))]
      (assert (= (.-exitCode res2) 0) "cli.asl syntax check cleanly")
      (refute (!= (.-exitCode res2) 0) "check must exit 0"))
    true))

(df RunTests [] -> Bool
  (do
    (assert (testTaskRegistration) "testTaskRegistration passed")
    (assert (testPhase502TaskFixtures) "testPhase502TaskFixtures passed")
    (assert (testCliAndBatchIntegration) "testCliAndBatchIntegration passed")
    true))
