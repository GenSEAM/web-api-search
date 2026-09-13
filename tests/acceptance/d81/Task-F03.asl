(module tests/acceptance/d81/Task-F03
  :d "Acceptance fixture for Task-F03: Repair Native Pre-Commit Hook Executable Target under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestPreCommitHookExists
      TestPreCommitHookTargetsBinAsl
      TestTaskF03GroundedInPhaseFINSEL]
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

(df TestPreCommitHookExists [] -> Bool
  :d "Verifies that asl/tools/hooks/pre-commit exists and is readable"
  (let [(h-res (file-read "asl/tools/hooks/pre-commit"))]
    (assert (= (.-_tag h-res) "ok") "pre-commit hook file must exist and be readable")
    (let [(h-src (.-value h-res))]
      (assert (string-contains? h-src "ROOT_DIR") "Must define ROOT_DIR")
      true)))

(df TestPreCommitHookTargetsBinAsl [] -> Bool
  :d "Verifies that pre-commit invokes bin/asl and does not attempt to execute asl directory"
  (let [(h-res (file-read "asl/tools/hooks/pre-commit"))]
    (assert (= (.-_tag h-res) "ok") "pre-commit hook file must exist and be readable")
    (let [(h-src (.-value h-res))]
      (assert (string-contains? h-src "bin/asl\" gate") "Must invoke bin/asl gate")
      (assert (not (string-contains? h-src "exec \"$ROOT_DIR/asl\" gate")) "Must not execute directory $ROOT_DIR/asl")
      true)))

(df TestTaskF03GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F03 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F03\"") "Must declare Task-F03")
      (assert (string-contains? f-src "asl/tools/hooks/pre-commit") "Must own pre-commit hook")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F03 acceptance checks"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestPreCommitHookExists) "TestPreCommitHookExists must pass")
    (assert (TestPreCommitHookTargetsBinAsl) "TestPreCommitHookTargetsBinAsl must pass")
    (assert (TestTaskF03GroundedInPhaseFINSEL) "TestTaskF03GroundedInPhaseFINSEL must pass")
    true))
