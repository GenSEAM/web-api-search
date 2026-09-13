(module tests/acceptance/d81/Task48402
  :d "Test Task48402.asl"
  :x [runTests]
  :i [])

(df testAslNoteWrite [] -> Bool
  (let [(res (sysExec "./asl/bin/asl note write --fact 'Test note'"))
        (code (.-exitCode res))]
    (assert (= code 0) "Note write command succeeds")
    (refute (!= code 0) "Note write must exit 0")
    true))
(df runTests [] -> Bool (do 
  (assert (testAslNoteWrite) "test-asl-note-write passes")
  true))
