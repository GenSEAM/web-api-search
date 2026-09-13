(module tests/acceptance/d81/Task50706
  :d "Acceptance fixture for Task 50706: Dynamic End-to-End WASI Engine Execution, Dual-Polarity Gate & Task Registration"
  :x [testWasiRuntimeDynamicExecution
      testWasiRuntimeInvariants
      testWasiRuntimeDualPolarityRefutations
      RunTests]
  :i [(../../../asl/packages/asl-compiler/src/wasm :a w)
      (../../../asl/packages/asl-compiler/src/wasi :a wasi)
      (../../../asl/packages/asl-compiler/src/vfs_git :a vfs)])

(df testWasiRuntimeDynamicExecution [] -> Bool
  :d "Dynamically runs the wasi_runtime_test suite via bin/asl CLI"
  (let [(res (sys-exec "bin/asl test asl/packages/asl-compiler/tests/wasi_runtime_test.asl"))
        (code (.-exitCode res))
        (stdout (.-stdout res))]
    (assert (= code 0) (str "wasi_runtime_test must exit 0, output: " stdout))
    (refute (!= code 0) "wasi_runtime_test must not fail")
    (assert (string-contains? stdout "assertion(s) executed") "wasi_runtime_test must report executed assertions")
    (assert (string-contains? stdout "refutation(s) executed") "wasi_runtime_test must report executed refutations")
    (refute (string-contains? stdout "ASL_ASSERTION_FAILURE") "wasi_runtime_test must not fail assertions")
    true))

(df testWasiRuntimeInvariants [] -> Bool
  :d "Directly verifies dynamic WASI execution, disk I/O, Git VFS, and task registration"
  (let [(execRes (sys-exec "/usr/local/bin/node /tmp/run_dynamic_wasi.js"))
        (code (.-exitCode execRes))
        (out (.-stdout execRes))]
    (assert (= code 0) (str "Dynamic WASI execution must exit 0, output: " out))
    (refute (!= code 0) "Dynamic WASI execution must not fail")
    (assert (string-contains? out "Hello, WASI!") "WASI execution must capture stdout via fd_write")
    (assert (string-contains? out "WASI_EXIT_CODE:0") "WASI execution must exit 0 via proc_exit")
    (let [(testFile "/tmp/test_wasi_task50706.txt")
          (testData "SOVEREIGN_WASI_ACCEPTANCE_50706")
          (wRes (wasi/wasiFileWrite testFile testData))]
      (assert (= (.-_tag wRes) "ok") "wasiFileWrite must succeed")
      (assert (wasi/wasiFileExists? testFile) "wasiFileExists? must verify file on disk")
      (let [(rRes (wasi/wasiFileRead testFile))]
        (assert (= (.-_tag rRes) "ok") "wasiFileRead must succeed")
        (mt rRes
          ((ok text) (assert (= text testData) "Read text must match written text"))
          ((err _) (assert false "wasiFileRead returned error"))))
      (let [(bRes (vfs/gitCurrentBranch ""))
            (cRes (vfs/gitHeadCommit ""))]
        (assert (= (.-_tag bRes) "ok") "gitCurrentBranch must succeed")
        (assert (= (.-_tag cRes) "ok") "gitHeadCommit must succeed")
        (mt cRes
          ((ok sha) (assert (= (string-length sha) 40) "HEAD commit must be 40-char hex SHA"))
          ((err _) (assert false "gitHeadCommit returned error"))))
      (let [(taskPath ".asl/mem/tasks/Phase507PureAslWasiRuntime.asn")
            (tRes (file-read taskPath))]
        (assert (= (.-_tag tRes) "ok") "Task registration file must exist")
        (mt tRes
          ((ok content)
           (do
             (assert (string-contains? content "Phase507PureAslWasiRuntime") "Task collection must be registered")
             (assert (string-contains? content "Task50701") "Task 50701 must be registered")
             (assert (string-contains? content "Task50702") "Task 50702 must be registered")
             (assert (string-contains? content "Task50703") "Task 50703 must be registered")
             (assert (string-contains? content "Task50704") "Task 50704 must be registered")
             (assert (string-contains? content "Task50705") "Task 50705 must be registered")
             (assert (string-contains? content "Task50706") "Task 50706 must be registered")
             true))
          ((err _) (assert false "Task registration file read failed")))))
    true))

(df testWasiRuntimeDualPolarityRefutations [] -> Bool
  :d "Verifies dual-polarity refutations under D77"
  (let [(sandboxed (wasi/sandboxedWasiCapabilities))
        (receipt (wasi/wasiSysExec "forbidden_cmd" sandboxed))
        (taskContent (option-or (mt (file-read ".asl/mem/tasks/Phase507PureAslWasiRuntime.asn") ((ok c) (some c)) ((err _) (none))) ""))]
    (refute (wasi/wasiCapabilityCheck "execCmd" sandboxed) "execCmd must be refuted under sandbox")
    (refute (wasi/wasiCapabilityCheck "sys-exec" sandboxed) "sys-exec must be refuted under sandbox")
    (refute (= (option-or (map-get receipt "status") "") "ok") "Subprocess execution must not be permitted")
    (refute (!= (option-or (map-get receipt "code") -1) 126) "Refusal code must not deviate from 126")
    (refute (wasi/wasiFileExists? "/tmp/definitely_absent_task50706_file_99999.txt") "Non-existent file must not exist")
    (refute (= (.-_tag (vfs/gitReadHead "/tmp/non_existent_repo_dir_99999")) "ok") "gitReadHead must refute invalid directory")
    (refute (string-contains? taskContent "Task50799") "Task collection must not contain spurious tasks")
    (refute (string-empty? taskContent) "Task collection content must not be empty")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50706 acceptance tests"
  (do
    (assert (testWasiRuntimeDynamicExecution) "testWasiRuntimeDynamicExecution must pass")
    (assert (testWasiRuntimeInvariants) "testWasiRuntimeInvariants must pass")
    (assert (testWasiRuntimeDualPolarityRefutations) "testWasiRuntimeDualPolarityRefutations must pass")
    true))
