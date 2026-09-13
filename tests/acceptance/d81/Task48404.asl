(module tests/acceptance/d81/Task48404
  :d "Test Task48404.asl"
  :x [runTests]
  :i [])

(df testAslDoctor [] -> Bool
  (let [(res (sysExec "./asl/bin/asl doctor"))
        (code (.-exitCode res))]
    (assert (= code 0) "Doctor command succeeds")
    (refute (!= code 0) "Doctor must exit 0")
    true))
(df runTests [] -> Bool (do 
  (assert (testAslDoctor) "test-asl-doctor passes")
  true))
