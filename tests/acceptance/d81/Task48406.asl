(module tests/acceptance/d81/Task48406
  :d "Test Task48406.asl"
  :x [runTests]
  :i [])

(df testAslCheck [] -> Bool
  (let [(res (sysExec "./asl/bin/asl check .asl.config.asn"))
        (code (.-exitCode res))]
    (assert (= code 0) "Check command succeeds")
    (refute (!= code 0) "Check must exit 0")
    true))
(df runTests [] -> Bool (do 
  (assert (testAslCheck) "test-asl-check passes")
  true))
