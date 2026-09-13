(module tests/acceptance/d81/Task48403
  :d "Test Task48403.asl"
  :x [runTests]
  :i [])

(df testAslInventory [] -> Bool
  (let [(res (sysExec "./asl/bin/asl inventory"))
        (code (.-exitCode res))]
    (assert (= code 0) "Inventory command succeeds")
    (refute (!= code 0) "Inventory must exit 0")
    true))
(df runTests [] -> Bool (do 
  (assert (testAslInventory) "test-asl-inventory passes")
  true))
