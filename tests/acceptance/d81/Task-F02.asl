(module tests/acceptance/d81/Task-F02
  :d "Acceptance fixture for Task-F02: Implement Live Argument Parsing in CLI Gate Command under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestCliSourceGateValidation
      TestCliUnitTestsValidateGateFailure
      TestCSourceGateTargetValidation
      TestTaskF02GroundedInPhaseFINSEL]
  :i [])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task-F[0-9][0-9]") "Must validate Task-F pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestCliSourceGateValidation [] -> Bool
  :d "Verifies that asl/packages/asl-cli/src/cli.asl performs live file reading and error checking on gate arguments"
  (let [(c-res (file-read "asl/packages/asl-cli/src/cli.asl"))]
    (assert (= (.-_tag c-res) "ok") "asl-cli/src/cli.asl must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "check-gate-files") "CLI must define check-gate-files function")
      (assert (string-contains? c-src "file-read") "CLI gate handler must invoke file-read")
      (assert (string-contains? c-src "Failed to read gate target file") "CLI gate handler must report missing gate targets")
      true)))

(df TestCliUnitTestsValidateGateFailure [] -> Bool
  :d "Verifies that asl/packages/asl-cli unit test suites assert failure on non-existent gate files"
  (let [(t1-res (file-read "asl/packages/asl-cli/tests/cli-test.asl"))
        (t2-res (file-read "asl/packages/asl-cli/tests/cli_test.asl"))]
    (assert (= (.-_tag t1-res) "ok") "cli-test.asl must exist and be readable")
    (assert (= (.-_tag t2-res) "ok") "cli_test.asl must exist and be readable")
    (let [(t1-src (.-value t1-res))
          (t2-src (.-value t2-res))]
      (assert (string-contains? t1-src "non-existent") "cli-test.asl must test non-existent gate file")
      (assert (string-contains? t2-src "non-existent") "cli_test.asl must test non-existent gate file")
      true)))

(df TestCSourceGateTargetValidation [] -> Bool
  :d "Verifies that asl/tools/asl.c run_cmd_gate validates target file arguments"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "Target file not found") "asl.c run_cmd_gate must report target file not found")
      (assert (string-contains? c-src "file_args_count") "asl.c run_cmd_gate must count and validate target file arguments")
      true)))

(df TestTaskF02GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F02 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F02\"") "Must declare Task-F02")
      (assert (string-contains? f-src "asl/packages/asl-cli/src/cli.asl") "Must own asl-cli/src/cli.asl")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F02 acceptance checks"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestCliSourceGateValidation) "TestCliSourceGateValidation must pass")
    (assert (TestCliUnitTestsValidateGateFailure) "TestCliUnitTestsValidateGateFailure must pass")
    (assert (TestCSourceGateTargetValidation) "TestCSourceGateTargetValidation must pass")
    (assert (TestTaskF02GroundedInPhaseFINSEL) "TestTaskF02GroundedInPhaseFINSEL must pass")
    true))
