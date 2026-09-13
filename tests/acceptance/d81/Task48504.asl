(module tests/acceptance/d81/Task48504
  :d "Task 485 test"
  :x [runTests]
  :i [])

(df runTests [] -> Bool
  (let [(res (sysExec "bin/asl launch agy --dry-run"))
        (code (.-exitCode res))
        (out (.-stdout res))]
    (assert (= code 0) "Command succeeds")
    (assert (string-contains? out "(:invocation_plan") "has invocation plan")
    (refute (string-contains? out "Error") "no error message")
    true))
