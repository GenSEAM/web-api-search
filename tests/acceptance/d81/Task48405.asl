(module tests/acceptance/d81/Task48405
  :d "Test Task48405.asl"
  :x [runTests]
  :i [])

(df testAslReflect [] -> Bool
  (let [(res (sysExec "./asl/bin/asl reflect fake-id"))
        (code (.-exitCode res))]
    (assert (> code 0) "Reflect command should fail on fake-id")
    (refute (= code 0) "Should not exit 0")
    true))
(df runTests [] -> Bool (do 
  (assert (testAslReflect) "test-asl-reflect passes")
  true))
