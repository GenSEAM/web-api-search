(module tests/acceptance/d81/Task48407
  :d "Test Task48407.asl"
  :x [runTests]
  :i [])

(df testAslGate [] -> Bool
  (let [(res (sysExec "./asl/bin/asl gate"))
        (code (.-exitCode res))]
    (assert (>= code 0) "Gate command executes")
    (refute (string-contains? (.-stdout res) "Error") "Output has no errors")
    true))
(df runTests [] -> Bool (do 
  (assert (testAslGate) "test-asl-gate passes")
  true))
