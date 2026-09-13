(module phase488/task4
  :d "Test Embedded SQLite Storage Engine Adapter"
  :x [runTests])
(df runTests [] -> Bool
  (let [(res (sysExec "./asl/bin/asl wasm sqlite 'SELECT 1'"))]
    (assert (= (.-exitCode res) 0) "SQLite query should succeed")
    (assert (string-contains? (.-stdout res) ":action :sqlite") "Action is sqlite")
    (refute (string-contains? (.-stdout res) "Error") "No error in output")
    true))
