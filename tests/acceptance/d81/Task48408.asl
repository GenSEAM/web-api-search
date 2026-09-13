(module tests/acceptance/d81/Task48408
  :d "Test Task48408.asl"
  :x [runTests]
  :i [])

(df testAslAuditConsistency [] -> Bool
  (let [(res (sysExec "./asl/bin/asl audit consistency"))
        (code (.-exitCode res))]
    (assert (>= code 0) "Consistency audit executes")
    (refute (string-contains? (.-stdout res) "Error") "Output has no errors")
    true))
(df runTests [] -> Bool (do 
  (assert (testAslAuditConsistency) "test-asl-audit-consistency passes")
  true))
