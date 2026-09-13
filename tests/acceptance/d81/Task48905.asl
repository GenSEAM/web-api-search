(module phase489/task5
  :d "Test Full Monorepo Master Gate Certification"
  :x [runTests])
(df runTests [] -> Bool
  (let [(res (sysExec "./asl/bin/asl epistemic verify all"))]
    (assert (= (.-exitCode res) 0) "Master gate should succeed")
    (assert (string-contains? (.-stdout res) "all") "Action includes all")
    (refute (= (.-exitCode res) 127) "Should not be 127")
    true))
