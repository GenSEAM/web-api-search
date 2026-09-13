(module tests/acceptance/d81/Task-F06
  :d "Acceptance fixture for Task-F06: Eliminate Caller-Supplied Magic Numbers in Gate Runner under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestLiveGateAuditExported
      TestRunLiveGateAuditInspectsDisk
      TestTaskF06GroundedInPhaseFINSEL]
  :i [(asl-gates/gate-runner :a gr)])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task-F[0-9][0-9]") "Must validate Task-F pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestLiveGateAuditExported [] -> Bool
  :d "Verifies that gate_runner.asl exports run-live-gate-audit"
  (let [(c-res (file-read "asl/packages/asl-gates/src/gate_runner.asl"))]
    (assert (= (.-_tag c-res) "ok") "gate_runner.asl must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "run-live-gate-audit") "gate_runner.asl must export run-live-gate-audit")
      true)))

(df TestRunLiveGateAuditInspectsDisk [] -> Bool
  :d "Verifies that run-live-gate-audit independently inspects disk without caller counts"
  (let [(summary (gr/run-live-gate-audit))]
    (assert (= (.-total-gates summary) 7) "Total gates count must equal 7")
    (assert (>= (.-passed-gates summary) 1) "At least one gate must evaluate cleanly from disk")
    (assert (= (list-length (.-verdicts summary)) 7) "Must have 7 verdicts")
    true))

(df TestTaskF06GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F06 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F06\"") "Must declare Task-F06")
      (assert (string-contains? f-src "gate_runner.asl") "Must own gate_runner.asl")
      (assert (string-contains? f-src "runner.asl") "Must own runner.asl")
      true)))

(df RunTests [] -> Bool
  :d "Runs all Task-F06 acceptance checks"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestLiveGateAuditExported) "TestLiveGateAuditExported must pass")
    (assert (TestRunLiveGateAuditInspectsDisk) "TestRunLiveGateAuditInspectsDisk must pass")
    (assert (TestTaskF06GroundedInPhaseFINSEL) "TestTaskF06GroundedInPhaseFINSEL must pass")
    true))
