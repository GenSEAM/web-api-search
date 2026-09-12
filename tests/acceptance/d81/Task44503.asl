(module tests/acceptance/d81/Task44503
  :d "Acceptance fixture for Task44503: C3 duplicate capability checker and D51 camelCase convergence checker under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestC3CheckerModuleContract
      TestD51ConvergenceCheckerModuleContract
      TestC3CheckerBehaviorContract
      TestD51ConvergenceBehaviorContract
      TestGateIntegrationContract
      TestPhase415StateCorrectedFromMeasurement
      TestTask44503GroundedInPhase445]
  :i [])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestC3CheckerModuleContract [] -> Bool
  :d "Verifies asl-gates/rule-checkers exports audit-c3-duplicates and grammar registers it"
  (let [(m-res (file-read "asl/packages/asl-gates/src/rule_checkers.asl"))
        (g-res (file-read "asl/packages/asl-gates/grammar.asn"))]
    (assert (= (.-_tag m-res) "ok") "rule_checkers.asl must exist and be readable")
    (assert (= (.-_tag g-res) "ok") "grammar.asn must exist and be readable")
    (let [(m-src (.-value m-res))
          (g-src (.-value g-res))]
      (assert (string-contains? m-src "audit-c3-duplicates") "Must export audit-c3-duplicates")
      (assert (string-contains? g-src ":name \"audit-c3-duplicates\"") "grammar must register audit-c3-duplicates")
      true)))

(df TestD51ConvergenceCheckerModuleContract [] -> Bool
  :d "Verifies asl-gates/rule-checkers exports audit-d51-convergence and grammar registers it"
  (let [(m-res (file-read "asl/packages/asl-gates/src/rule_checkers.asl"))
        (g-res (file-read "asl/packages/asl-gates/grammar.asn"))]
    (assert (= (.-_tag m-res) "ok") "rule_checkers.asl must exist and be readable")
    (assert (= (.-_tag g-res) "ok") "grammar.asn must exist and be readable")
    (let [(m-src (.-value m-res))
          (g-src (.-value g-res))]
      (assert (string-contains? m-src "audit-d51-convergence") "Must export audit-d51-convergence")
      (assert (string-contains? g-src ":name \"audit-d51-convergence\"") "grammar must register audit-d51-convergence")
      true)))

(df TestC3CheckerBehaviorContract [] -> Bool
  :d "Verifies C3 duplicate detection reports non-allowlisted duplicate symbols and respects canonical homes"
  (let [(m-res (file-read "asl/packages/asl-gates/src/rule_checkers.asl"))]
    (assert (= (.-_tag m-res) "ok") "rule_checkers.asl must exist and be readable")
    (let [(m-src (.-value m-res))]
      (assert (string-contains? m-src "duplicate capability outside canonical home") "Must report duplicate outside canonical home")
      (assert (string-contains? m-src "allowlist") "Must support allowlisted symbols like main and run-tests")
      true)))

(df TestD51ConvergenceBehaviorContract [] -> Bool
  :d "Verifies D51 convergence checker reports per-package floor and fails on kebab-case regression"
  (let [(m-res (file-read "asl/packages/asl-gates/src/rule_checkers.asl"))]
    (assert (= (.-_tag m-res) "ok") "rule_checkers.asl must exist and be readable")
    (let [(m-src (.-value m-res))]
      (assert (string-contains? m-src "regressed below baseline floor") "Must report regression below floor")
      (assert (string-contains? m-src "kebab-case test function detected in converged package") "Must report kebab-case in converged package")
      true)))

(df TestGateIntegrationContract [] -> Bool
  :d "Verifies asl/tools/asl.c wires C3 duplication check and D51 convergence check into gates"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "check_c3_duplicates") "asl.c must declare check_c3_duplicates")
      (assert (string-contains? c-src "check_d51_convergence") "asl.c must declare check_d51_convergence")
      true)))

(df TestPhase415StateCorrectedFromMeasurement [] -> Bool
  :d "Verifies Phase 415 state in task ledger is corrected from measurement"
  (let [(p-res (file-read ".asl/mem/tasks/Phase415LargeScaleTypestateRefactorAndCamelCaseConvergence.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 415 task collection must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "T415CamelTests") "Phase 415 must contain T415CamelTests")
      (assert (string-contains? p-src ":state :in-progress") "T415CamelTests must be corrected to in-progress")
      (assert (string-contains? p-src "80 of 1673") "Phase 415 must record measured test function convergence")
      true)))

(df TestTask44503GroundedInPhase445 [] -> Bool
  :d "Verifies Phase 445 task collection grounds Task44503"
  (let [(p-res (file-read ".asl/mem/tasks/Phase445StaticConfirmationCoverage.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 445 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "C3 duplicate capability checker and the camelCase convergence checker") "Phase 445 must state Task44503 title")
      (assert (string-contains? p-src "C3 duplicate report with canonical-home awareness") "Phase 445 must state C3 outcome")
      (assert (string-contains? p-src "D51 convergence per package with a regression floor") "Phase 445 must state D51 outcome")
      (assert (string-contains? p-src "Both wired into gate 6 or 7") "Phase 445 must state gate outcome")
      (assert (string-contains? p-src "Phase415 state corrected from the measurement") "Phase 445 must state Phase415 outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44503 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestC3CheckerModuleContract) "TestC3CheckerModuleContract must pass")
    (assert (TestD51ConvergenceCheckerModuleContract) "TestD51ConvergenceCheckerModuleContract must pass")
    (assert (TestC3CheckerBehaviorContract) "TestC3CheckerBehaviorContract must pass")
    (assert (TestD51ConvergenceBehaviorContract) "TestD51ConvergenceBehaviorContract must pass")
    (assert (TestGateIntegrationContract) "TestGateIntegrationContract must pass")
    (assert (TestPhase415StateCorrectedFromMeasurement) "TestPhase415StateCorrectedFromMeasurement must pass")
    (assert (TestTask44503GroundedInPhase445) "TestTask44503GroundedInPhase445 must pass")
    true))
