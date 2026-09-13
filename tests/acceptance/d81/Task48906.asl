(module phase489/task6
  :d "Test Sovereign Release Package"
  :x [runTests])
(df runTests [] -> Bool
  (let [(res (sysExec "./asl/bin/asl epistemic release pkg-1"))]
    (assert (= (.-exitCode res) 0) "Release should run")
    (assert (string-contains? (.-stdout res) ":action :release") "Status should be release")
    (refute (string-contains? (.-stdout res) "ERR") "No err")
    true))
