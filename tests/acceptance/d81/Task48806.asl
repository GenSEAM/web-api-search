(module phase488/task6
  :d "Test Ambient Substrate Supervise Gate"
  :x [runTests])
(df runTests [] -> Bool
  (let [(res (sysExec "./asl/bin/asl wasm run supervise.wasm"))]
    (assert (= (.-exitCode res) 0) "Supervise should run")
    (assert (string-contains? (.-stdout res) ":status :ok") "Status should be ok")
    (refute (string-contains? (.-stdout res) "ERR") "No err")
    true))
