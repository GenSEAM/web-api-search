(module phase488/task2
  :d "Test Pure ASL WebAssembly Runtime Core"
  :x [runTests])
(df runTests [] -> Bool
  (let [(res (sysExec "./asl/bin/asl wasm run core.wasm"))]
    (assert (= (.-exitCode res) 0) "Core should execute")
    (assert (string-contains? (.-stdout res) "core.wasm") "Output identifies core module")
    (refute (string-contains? (.-stdout res) "failed") "Should not fail")
    true))
