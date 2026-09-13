(module tests/acceptance/d81/Task50703
  :d "Acceptance fixture for Task 50703: Sandboxed Capability Security Boundary & Explicit sys-exec Refusal"
  :x [testWasiCapabilityDynamicExecution
      testWasiCapabilityInvariants
      testWasiCapabilityDualPolarityRefutations
      RunTests]
  :i [(../../../asl/packages/asl-compiler/src/wasi :a wasi)])

(df testWasiCapabilityDynamicExecution [] -> Bool
  :d "Dynamically runs the wasi_capability_test suite via bin/asl CLI"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-compiler/tests/wasi_capability_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "wasi_capability_test must exit 0, stderr: " (.-stderr res)))
    (refute (!= code 0) "wasi_capability_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "wasi_capability_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "wasi_capability_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "wasi_capability_test must not fail assertions")
    true))

(df testWasiCapabilityInvariants [] -> Bool
  :d "Directly verifies capability refusal receipt invariants"
  (let [(sandboxed (wasi/sandboxedWasiCapabilities))
        (receipt (wasi/wasiSysExec "date" sandboxed))]
    (assert (= (.-status receipt) "refused") "Status under sandbox must be refused")
    (assert (= (.-code receipt) 126) "Refusal code must be 126")
    (assert (string-contains? (.-stderr receipt) "ERR_CAPABILITY_DENIED") "Stderr must contain ERR_CAPABILITY_DENIED")
    (assert (= (.-stdout receipt) "") "Stdout must be empty on capability refusal")
    (refute (= (.-status receipt) "ok") "Status must not be ok")
    (refute (!= (.-code receipt) 126) "Code must not deviate from 126")
    true))

(df testWasiCapabilityDualPolarityRefutations [] -> Bool
  :d "Verifies dual-polarity refutations under D77"
  (let [(sandboxed (wasi/sandboxedWasiCapabilities))
        (res (wasi/wasiSysExec "echo should_not_run" sandboxed))]
    (refute (wasi/wasiCapabilityCheck "execCmd" sandboxed) "execCmd must not be granted in sandbox")
    (refute (wasi/wasiCapabilityCheck "sys-exec" sandboxed) "sys-exec must not be granted in sandbox")
    (refute (= (.-status res) "ok") "Subprocess execution must not succeed when capability is false")
    (refute (string-contains? (.-stdout res) "should_not_run") "Subprocess stdout must not leak when capability is false")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50703 acceptance tests"
  (do
    (assert (testWasiCapabilityDynamicExecution) "testWasiCapabilityDynamicExecution must pass")
    (assert (testWasiCapabilityInvariants) "testWasiCapabilityInvariants must pass")
    (assert (testWasiCapabilityDualPolarityRefutations) "testWasiCapabilityDualPolarityRefutations must pass")
    true))
