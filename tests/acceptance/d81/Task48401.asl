(module tests/acceptance/d81/Task48401
  :d "Test Task48401"
  :x [runTests]
  :i [])

(df testAslTaskList [] -> Bool
  (let [(res (sysExec "bin/asl task list"))
        (code (.-exitCode res))]
    (assert (= code 0) (strConcat "Task list command succeeds, output was: " (.-stdout res) " error: " (.-stderr res)))
    (refute (!= code 0) "Task list must exit 0")
    true))

(df runTests [] -> Bool (do 
  (assert (testAslTaskList) "test-asl-task-list passes")
  true))
