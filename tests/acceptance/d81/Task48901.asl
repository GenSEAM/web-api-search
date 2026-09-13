(module phase489/task1
  :d "Test Epistemic Closure Registry"
  :x [runTests])
(df runTests [] -> Bool
  (let [(res (sysExec "./asl/bin/asl epistemic verify tier-1"))]
    (assert (= (.-exitCode res) 0) "Verify should succeed")
    (assert (string-contains? (.-stdout res) ":action :verify") "Output must verify")
    (refute (string-contains? (.-stdout res) "Error") "No error")
    true))
