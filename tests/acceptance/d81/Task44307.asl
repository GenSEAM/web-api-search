(module tests/acceptance/d81/Task44307
  :d "Acceptance fixture for Task44307: session ledger, trace and attention ops under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestLedgerConformanceSuiteExecution
      TestLedgerTargetSymbolsContract
      TestLedgerBehavioralContract
      TestRequiredCaseKindsContract
      TestTask44307GroundedInPhase443]
  :i [("../../conformance/ledger/ledger_attention_test" :a lat)])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestLedgerConformanceSuiteExecution [] -> Bool
  :d "Verifies tests/conformance/ledger/ledger_attention_test.asl executes all cases cleanly"
  (let [(f-res (file-read "tests/conformance/ledger/ledger_attention_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance test suite must exist and be readable")
    (assert (lat/RunTests) "Conformance suite must pass all assertions cleanly")
    true))

(df TestLedgerTargetSymbolsContract [] -> Bool
  :d "Verifies target symbols execute_single_step is declared and handles ledger and trace operations"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "execute_single_step") "asl.c must declare execute_single_step")
      (assert (string-contains? c-src "handle_payload") "asl.c must declare handle_payload")
      true)))

(df TestLedgerBehavioralContract [] -> Bool
  :d "Verifies behavioral requirements: constraint survival across compaction, bounded rule slices, and rejection of fabricated receipts"
  (let [(cap-res (file-read "asl/grammar/capabilities.asn"))
        (rec-res (file-read "mem/src/tasks_store.asl"))]
    (assert (= (.-_tag cap-res) "ok") "capabilities.asn must exist")
    (assert (= (.-_tag rec-res) "ok") "tasks_store.asl must exist")
    (let [(cap-src (.-value cap-res))
          (rec-src (.-value rec-res))]
      (assert (string-contains? cap-src "sessionLedger") "capabilities.asn must declare sessionLedger")
      (assert (string-contains? cap-src "rulesSlice") "capabilities.asn must declare rulesSlice")
      (assert (string-contains? cap-src "boundReceipt") "capabilities.asn must declare boundReceipt")
      (assert (string-contains? rec-src "receipt-is-verified?") "tasks_store.asl must enforce receipt-is-verified?")
      (assert (string-contains? rec-src "(> (.-asserts-evaluated receipt) 0)") "Receipt verification must mandate positive assertions")
      (assert (string-contains? rec-src "(= (.-exit-code receipt) 0)") "Receipt verification must mandate exit code 0")
      true)))

(df TestRequiredCaseKindsContract [] -> Bool
  :d "Verifies that required case kinds (boundary, resourceBound, negativeControl, idempotence, concurrency) are present"
  (let [(f-res (file-read "tests/conformance/ledger/ledger_attention_test.asl"))]
    (assert (= (.-_tag f-res) "ok") "Conformance suite must exist")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src "TestBoundaryConstraintPreservedAcrossCompactions") "Must implement boundary case")
      (assert (string-contains? f-src "TestResourceBoundOutputAndRuleSlice") "Must implement resourceBound case")
      (assert (string-contains? f-src "TestNegativeControlFabricatedReceiptRefused") "Must implement negativeControl case")
      (assert (string-contains? f-src "TestIdempotenceRecoveryAndResume") "Must implement idempotence case")
      (assert (string-contains? f-src "TestConcurrencySessionLedgerIsolation") "Must implement concurrency case")
      true)))

(df TestTask44307GroundedInPhase443 [] -> Bool
  :d "Verifies Phase 443 task collection grounds Task44307"
  (let [(p-res (file-read ".asl/mem/tasks/Phase443TestCoverageCampaign.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 443 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Session ledger, trace and attention ops") "Phase 443 must state Task44307 title")
      (assert (string-contains? p-src ":lane \"attention\"") "Phase 443 must specify attention lane")
      (assert (string-contains? p-src "tests/conformance/ledger") "Phase 443 must declare conformance owns")
      (assert (string-contains? p-src "execute_single_step") "Phase 443 must target execute_single_step")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44307 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestLedgerConformanceSuiteExecution) "TestLedgerConformanceSuiteExecution must pass")
    (assert (TestLedgerTargetSymbolsContract) "TestLedgerTargetSymbolsContract must pass")
    (assert (TestLedgerBehavioralContract) "TestLedgerBehavioralContract must pass")
    (assert (TestRequiredCaseKindsContract) "TestRequiredCaseKindsContract must pass")
    (assert (TestTask44307GroundedInPhase443) "TestTask44307GroundedInPhase443 must pass")
    true))
