(module tests/acceptance/d81/Task-F15
  :d "Acceptance fixture for Task-F15: Implement Subprocess Execution and Pipe Engine in ASL Shell under ADR-0081."
  :x [RunTests
      TestExecSubprocessEcho
      TestExecSubprocessCatStdin
      TestPipeSubprocessStages
      TestTaskF15GroundedInPhaseFINSEL]
  :i [(asl-sh/process :a proc)
      (asl-sh/pipe :a pipe)])

(df TestExecSubprocessEcho [] -> Bool
  :d "Verifies exec! executing echo command returning structured process result"
  (let [(r (proc/exec! (proc/cmd "echo" (list "hello" "asl-sh"))))]
    (assert (= (.-_tag r) "ok") "echo execution must succeed")
    (let [(out (.-value r))]
      (assert (= (.-exit-code out) 0) "echo exit code must be 0")
      (assert (= (.-stdout out) "hello asl-sh") "echo stdout must match arguments")
      (assert (= (.-stderr out) "") "echo stderr must be empty")
      true)))

(df TestExecSubprocessCatStdin [] -> Bool
  :d "Verifies exec! executing cat with stdin input"
  (let [(cmd (proc/with-stdin (proc/cmd "cat" (list)) "piped input payload"))
        (r (proc/exec! cmd))]
    (assert (= (.-_tag r) "ok") "cat execution must succeed")
    (let [(out (.-value r))]
      (assert (= (.-exit-code out) 0) "cat exit code must be 0")
      (assert (= (.-stdout out) "piped input payload") "cat stdout must match stdin input")
      true)))

(df TestPipeSubprocessStages [] -> Bool
  :d "Verifies multi-stage pipeline execution piping stdout from echo to cat"
  (let [(pipeline (pipe/make-pipeline (list (proc/cmd "echo" (list "data stream"))
                                           (proc/cmd "cat" (list)))))
        (r (pipe/pipe! pipeline))]
    (assert (= (.-_tag r) "ok") "pipe execution must succeed")
    (let [(out (.-value r))]
      (assert (= (.-exit-code out) 0) "pipeline exit code must be 0")
      (assert (= (.-stdout out) "data stream") "pipeline final stage stdout must match")
      true)))

(df TestTaskF15GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F15 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F15\"") "Must declare Task-F15")
      (assert (string-contains? f-src "asl/packages/asl-sh/src/core/process.asl") "Must own process.asl")
      (assert (string-contains? f-src "asl/packages/asl-sh/src/core/pipe.asl") "Must own pipe.asl")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F15 acceptance checks"
  (do
    (assert (TestExecSubprocessEcho) "TestExecSubprocessEcho must pass")
    (assert (TestExecSubprocessCatStdin) "TestExecSubprocessCatStdin must pass")
    (assert (TestPipeSubprocessStages) "TestPipeSubprocessStages must pass")
    (assert (TestTaskF15GroundedInPhaseFINSEL) "TestTaskF15GroundedInPhaseFINSEL must pass")
    true))
