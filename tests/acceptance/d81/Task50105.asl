(module tests/acceptance/d81/Task50105
  :d "Acceptance fixture for Task 50105: Self-Hosted asl-sh & asl-eval Real Syscall Integration"
  :x [testProcessRealExecution testEvalSyscallBindings testProcessSuite RunTests]
  :i [(../../../asl/packages/asl-sh/src/core/process :a proc)
      (../../../asl/packages/asl-eval/src/eval :a ev)])

(df testProcessRealExecution [] -> Bool
  (let [(cmd (proc/cmd "sh" (list "-c" "echo real_process_50105_success")))
        (res (proc/exec! cmd))]
    (assert (= (.-_tag res) "ok") "proc/exec! with real shell command succeeds")
    (refute (!= (.-_tag res) "ok") "proc/exec! must not return error on real command")
    (mt res
      ((ok out)
       (do
         (assert (= (.-exitCode out) 0) "exitCode is 0")
         (refute (!= (.-exitCode out) 0) "exitCode must be 0")
         (assert (string-contains? (.-stdout out) "real_process_50105_success") "stdout contains process output")
         (refute (not (string-contains? (.-stdout out) "real_process_50105_success")) "stdout must contain expected string")
         true))
      ((err _) false))))

(df testEvalSyscallBindings [] -> Bool
  (let [(env (ev/makeEvalEnv))
        (bindings (.-bindings env))]
    (assert (list-contains? bindings "dirList") "evalEnv contains dirList")
    (refute (not (list-contains? bindings "dirList")) "dirList binding must be in evalEnv")
    (assert (list-contains? bindings "execCmd") "evalEnv contains execCmd")
    (refute (not (list-contains? bindings "execCmd")) "execCmd binding must be in evalEnv")
    (assert (list-contains? bindings "fileStat") "evalEnv contains fileStat")
    (refute (not (list-contains? bindings "fileStat")) "fileStat binding must be in evalEnv")
    (assert (list-contains? bindings "pathCanonicalize") "evalEnv contains pathCanonicalize")
    (refute (not (list-contains? bindings "pathCanonicalize")) "pathCanonicalize binding must be in evalEnv")
    true))

(df testProcessSuite [] -> Bool
  (let [(res (sys-exec "bin/asl test --strict-falsify asl/packages/asl-sh/tests/process_test.asl"))
        (code (.-exitCode res))]
    (assert (= code 0) (str "asl-sh process_test.asl passes, stderr=" (.-stderr res)))
    (refute (!= code 0) "asl-sh process_test.asl must exit 0")
    true))

(df RunTests [] -> Bool
  (do
    (assert (testProcessRealExecution) "testProcessRealExecution passes")
    (assert (testEvalSyscallBindings) "testEvalSyscallBindings passes")
    (assert (testProcessSuite) "testProcessSuite passes")
    true))
