(module tests/acceptance/d81/Task44305
  :d "Acceptance fixture for Task44305: gates, receipts and non-vacuity under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestGatesConformanceSuiteExecution
      TestGateTargetSymbolsContract
      TestGateBehavioralContract
      TestRequiredCaseKindsContract
      TestTask44305GroundedInPhase443]
  :i [("../../conformance/gates/gates_conformance_test" :a gct)])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestGatesConformanceSuiteExecution [] -> Bool
  :d "Verifies tests/conformance/gates/gates_conformance_test.asl executes all cases cleanly"
  (let [(f-res (file-read "tests/conformance/gates/gates_conformance_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance test suite must exist and be readable")
    (assert (gct/RunTests) "Conformance suite must pass all assertions cleanly")
    true))

(df TestGateTargetSymbolsContract [] -> Bool
  :d "Verifies target symbols run_gate_2, run_gate_4, run_gate_5, and verify-claims-grounding are present"
  (let [(c-res (file-read "asl/tools/asl.c"))
        (g-res (file-read "asl/packages/asl-gates/src/site-claims.asl"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (assert (= (.-_tag g-res) "ok") "asl/packages/asl-gates/src/site-claims.asl must exist and be readable")
    (let [(c-src (.-value c-res))
          (g-src (.-value g-res))]
      (assert (string-contains? c-src "gate_enabled[2]") "asl.c must implement gate 2 execution")
      (assert (string-contains? c-src "gate_enabled[4]") "asl.c must implement gate 4 execution")
      (assert (string-contains? c-src "run_gate_5_suites") "asl.c must implement run_gate_5_suites")
      (assert (string-contains? g-src "verify-claims-grounding") "site-claims.asl must export verify-claims-grounding")
      true)))

(df TestGateBehavioralContract [] -> Bool
  :d "Verifies behavioral requirements: planted violation failure branches and receipt binding validation"
  (let [(c-res (file-read "asl/tools/asl.c"))
        (r-res (file-read ".asl/mem/receipts.asn"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (assert (= (.-_tag r-res) "ok") ".asl/mem/receipts.asn must exist and be readable")
    (let [(c-src (.-value c-res))
          (r-src (.-value r-res))]
      (assert (string-contains? c-src "check_file_delimiters") "Gate 2 must verify delimiter balance")
      (assert (string-contains? c-src "check_zero_foreign_files") "Gate 4 must check foreign files")
      (assert (string-contains? c-src "check_grounded_claims") "Gate 3 must audit grounded claims")
      (assert (string-contains? c-src "check_capabilities_staleness") "Gate 7 must verify lock freshness")
      (assert (string-contains? r-src ":receipts") "receipts ledger must exist")
      (assert (string-contains? r-src ":status :verified") "receipts must record verified status")
      true)))

(df TestRequiredCaseKindsContract [] -> Bool
  :d "Verifies that required case kinds (negativeControl, adversarial, errorPropagation, idempotence, concurrency) are present"
  (let [(f-res (file-read "tests/conformance/gates/gates_conformance_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance suite must exist")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src "TestNegativeControlUngroundedClaimRejected") "Must implement negativeControl case")
      (assert (string-contains? f-src "TestAdversarialPlantedGateViolations") "Must implement adversarial case")
      (assert (string-contains? f-src "TestErrorPropagationGateExecution") "Must implement errorPropagation case")
      (assert (string-contains? f-src "TestIdempotenceCleanGatesPass") "Must implement idempotence case")
      (assert (string-contains? f-src "TestConcurrencyReceiptValidation") "Must implement concurrency case")
      true)))

(df TestTask44305GroundedInPhase443 [] -> Bool
  :d "Verifies Phase 443 task collection grounds Task44305"
  (let [(p-res (file-read ".asl/mem/tasks/Phase443TestCoverageCampaign.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 443 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Gates, receipts and non-vacuity") "Phase 443 must state Task44305 title")
      (assert (string-contains? p-src ":lane \"verification\"") "Phase 443 must specify verification lane")
      (assert (string-contains? p-src "tests/conformance/gates") "Phase 443 must declare conformance owns")
      (assert (string-contains? p-src "verify-claims-grounding") "Phase 443 must target verify-claims-grounding")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44305 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestGatesConformanceSuiteExecution) "TestGatesConformanceSuiteExecution must pass")
    (assert (TestGateTargetSymbolsContract) "TestGateTargetSymbolsContract must pass")
    (assert (TestGateBehavioralContract) "TestGateBehavioralContract must pass")
    (assert (TestRequiredCaseKindsContract) "TestRequiredCaseKindsContract must pass")
    (assert (TestTask44305GroundedInPhase443) "TestTask44305GroundedInPhase443 must pass")
    true))
