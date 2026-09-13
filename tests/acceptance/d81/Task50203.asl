(module tests/acceptance/d81/Task50203
  :d "Acceptance fixture for Task50203: Pure ASL CLI RPC dispatcher wiring and direct S-expression dispatch."
  :x [testCliTestSuite testDirectSexpressionDispatch testDirectStepDispatch testRpcCommandDispatch testGrammarRegistration testCliGateIntegrity RunTests]
  :i [])

(df testCliTestSuite [] -> Bool
  (let [(res (sys-exec "bin/asl test --strict-falsify asl/packages/asl-cli/tests/cli_test.asl"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "cli_test.asl must pass cleanly")
    (refute (!= code 0) "cli_test.asl must not fail")
    (assert (string-contains? out "assertion(s) executed") "cli_test.asl ran assertions")
    (refute (string-contains? out "0 assertion(s) executed") "cli_test.asl is non-vacuous")
    true))

(df testDirectSexpressionDispatch [] -> Bool
  (let [(res (sys-exec "bin/asl '(:batch (:echo :message \"shorthand-batch-verified\"))'"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "direct batch shorthand exits 0")
    (refute (!= code 0) "direct batch shorthand must not fail")
    (assert (string-contains? out ":batch-res") "envelope contains :batch-res")
    (assert (string-contains? out ":status \"completed\"") "batch completed")
    (assert (string-contains? out "shorthand-batch-verified") "payload echoed")
    (refute (string-contains? out "Unknown command") "command recognized cleanly")
    true))

(df testDirectStepDispatch [] -> Bool
  (let [(res (sys-exec "bin/asl '(:echo :message \"shorthand-step-verified\")'"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "direct step shorthand exits 0")
    (refute (!= code 0) "direct step shorthand must not fail")
    (assert (string-contains? out ":batch-res") "envelope contains :batch-res")
    (assert (string-contains? out ":status \"completed\"") "step completed")
    (assert (string-contains? out "shorthand-step-verified") "payload echoed")
    (refute (string-contains? out "Unknown command") "step recognized cleanly")
    true))

(df testRpcCommandDispatch [] -> Bool
  (let [(res (sys-exec "bin/asl rpc '(:batch (:echo :message \"rpc-cmd-verified\"))'"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "rpc command exits 0")
    (refute (!= code 0) "rpc command must not fail")
    (assert (string-contains? out ":batch-res") "envelope contains :batch-res")
    (assert (string-contains? out ":status \"completed\"") "batch completed")
    (assert (string-contains? out "rpc-cmd-verified") "payload echoed")
    (refute (string-contains? out "Unknown command") "rpc command recognized")
    true))

(df testGrammarRegistration [] -> Bool
  (let [(res (sys-exec "sh -c 'cat asl/packages/asl-cli/grammar.asn'"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "grammar.asn readable")
    (refute (!= code 0) "grammar.asn read must exit 0")
    (assert (string-contains? out "dispatchRpc") "dispatchRpc registered in grammar")
    (assert (string-contains? out "evalBatch") "evalBatch registered in grammar")
    (refute (string-contains? out "dispatchAsn") "dead symbol dispatchAsn purged")
    true))

(df testCliGateIntegrity [] -> Bool
  (let [(chkRes (sys-exec "bin/asl check asl/packages/asl-cli/src/cli.asl"))
        (gateRes (sys-exec "bin/asl gate asl/packages/asl-cli/src/cli.asl"))]
    (assert (= (.-exitCode chkRes) 0) "cli.asl delimiter balance and syntax valid")
    (refute (!= (.-exitCode chkRes) 0) "cli.asl check must exit 0")
    (assert (= (.-exitCode gateRes) 0) "cli.asl passes monorepo gate verification")
    (refute (!= (.-exitCode gateRes) 0) "cli.asl gate must exit 0")
    true))

(df RunTests [] -> Bool
  (do
    (assert (testCliTestSuite) "testCliTestSuite passes")
    (assert (testDirectSexpressionDispatch) "testDirectSexpressionDispatch passes")
    (assert (testDirectStepDispatch) "testDirectStepDispatch passes")
    (assert (testRpcCommandDispatch) "testRpcCommandDispatch passes")
    (assert (testGrammarRegistration) "testGrammarRegistration passes")
    (assert (testCliGateIntegrity) "testCliGateIntegrity passes")
    true))
