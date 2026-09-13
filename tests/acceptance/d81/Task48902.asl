(module phase489/task2
  :d "Test 10-Tier Master Verification Engine"
  :x [runTests])
(df runTests [] -> Bool
  (let [(res (sysExec "./asl/bin/asl epistemic verify tier-10"))]
    (assert (= (.-exitCode res) 0) "Engine execute")
    (assert (string-contains? (.-stdout res) "tier-10") "Output identifies tier")
    (refute (= (.-exitCode res) 1) "Should not fail")
    true))
