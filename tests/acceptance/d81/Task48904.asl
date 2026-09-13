(module phase489/task4
  :d "Test Milestone M09 Epistemic Settlement"
  :x [runTests])
(df runTests [] -> Bool
  (let [(res (sysExec "./asl/bin/asl epistemic settle M09"))]
    (assert (= (.-exitCode res) 0) "Settle should succeed")
    (assert (string-contains? (.-stdout res) ":action :settle") "Action is settle")
    (refute (string-contains? (.-stdout res) "failed") "No failure")
    true))
