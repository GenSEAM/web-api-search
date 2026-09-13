(module phase488/task3
  :d "Test OPFS Deterministic Storage Adapter"
  :x [runTests])
(df runTests [] -> Bool
  (let [(res (sysExec "./asl/bin/asl wasm opfs write /file.txt"))]
    (assert (= (.-exitCode res) 0) "OPFS write should succeed")
    (assert (string-contains? (.-stdout res) ":action :opfs") "Action is opfs")
    (refute (= (.-exitCode res) 1) "Exit code should not be 1")
    true))
