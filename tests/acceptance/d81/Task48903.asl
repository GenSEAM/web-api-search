(module phase489/task3
  :d "Test Automated Ungrounded Claim Refutation"
  :x [runTests])
(df runTests [] -> Bool
  (let [(res (sysExec "./asl/bin/asl epistemic refute claim-x"))]
    (assert (= (.-exitCode res) 0) "Refute should succeed")
    (assert (string-contains? (.-stdout res) ":action :refute") "Action is refute")
    (refute (= (.-exitCode res) 2) "Exit code should not be 2")
    true))
