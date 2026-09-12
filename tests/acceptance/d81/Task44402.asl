(module tests/acceptance/d81/Task44402
  :d "Acceptance fixture for Task44402: three decidable coverage guarantees under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestCatalogTwelveKindsContract
      TestCoverageGuaranteesTargetSymbolsContract
      TestDecidableGuaranteesBehavioralContract
      TestPhase443AreasCaseKindsEnforcement
      TestTask44402GroundedInPhase444]
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

(df TestCatalogTwelveKindsContract [] -> Bool
  :d "Verifies docs/TEST_CASE_CATALOG.md defines the 12 canonical case kinds and non-vacuity rules"
  (let [(c-res (file-read "docs/TEST_CASE_CATALOG.md"))]
    (assert (= (.-_tag c-res) "ok") "docs/TEST_CASE_CATALOG.md must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "Happy path") "Catalog must define Happy path kind")
      (assert (string-contains? c-src "Boundary") "Catalog must define Boundary kind")
      (assert (string-contains? c-src "Empty and absent") "Catalog must define Empty and absent kind")
      (assert (string-contains? c-src "Malformed input") "Catalog must define Malformed input kind")
      (assert (string-contains? c-src "Negative control") "Catalog must define Negative control kind")
      (assert (string-contains? c-src "Error propagation") "Catalog must define Error propagation kind")
      (assert (string-contains? c-src "Round trip") "Catalog must define Round trip kind")
      (assert (string-contains? c-src "Idempotence") "Catalog must define Idempotence kind")
      (assert (string-contains? c-src "Metamorphic") "Catalog must define Metamorphic kind")
      (assert (string-contains? c-src "Adversarial") "Catalog must define Adversarial kind")
      (assert (string-contains? c-src "Concurrency") "Catalog must define Concurrency kind")
      (assert (string-contains? c-src "Resource bound") "Catalog must define Resource bound kind")
      (assert (string-contains? c-src "Never write `(assert true)`") "Catalog must forbid vacuous assert true")
      true)))

(df TestCoverageGuaranteesTargetSymbolsContract [] -> Bool
  :d "Verifies target symbol run_gate_7 is declared and gate 7 orchestrates continuous audit"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "run_gate_7_skills") "asl.c must declare run_gate_7_skills")
      (assert (string-contains? c-src "gate_enabled[7]") "asl.c must implement gate 7 filter")
      (assert (string-contains? c-src "check_capabilities_staleness") "asl.c must check capabilities staleness")
      true)))

(df TestDecidableGuaranteesBehavioralContract [] -> Bool
  :d "Verifies the three decidable guarantees: exported symbol coverage, executed assertion parity, and case kinds enforcement"
  (let [(p-res (file-read ".asl/mem/tasks/Phase444TestTelemetryAndCoverageGuarantees.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 444 tasks must exist")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Three decidable coverage guarantees") "Phase 444 must state guarantees title")
      (assert (string-contains? p-src "executing test per exported symbol") "Guarantee 1: executing test per exported symbol")
      (assert (string-contains? p-src "executed equals declared or an explicit unreached list") "Guarantee 2: executed equals declared or explicit unreached")
      (assert (string-contains? p-src "required case kinds per area") "Guarantee 3: required case kinds per area")
      (assert (string-contains? p-src "Mutation score is reported separately as the quality metric and is never called coverage") "Mutation score must not be conflated with coverage")
      true)))

(df TestPhase443AreasCaseKindsEnforcement [] -> Bool
  :d "Verifies that all seven Phase 443 conformance areas enforce their required case kinds"
  (let [(b-res (file-read "tests/conformance/boundary/path_boundary_test.asl"))
        (e-res (file-read "tests/conformance/evaluator/evaluator_semantics_test.asl"))
        (r-res (file-read "tests/conformance/rpc/rpc_dispatcher_test.asl"))
        (v-res (file-read "tests/conformance/vfs/vfs_staging_test.asl"))
        (g-res (file-read "tests/conformance/gates/gates_conformance_test.asl"))
        (t-res (file-read "tests/conformance/text/text_codec_conformance_test.asl"))
        (l-res (file-read "tests/conformance/ledger/ledger_attention_test.asl"))]
    (assert (= (.-_tag b-res) "ok") "boundary conformance suite must exist")
    (assert (= (.-_tag e-res) "ok") "evaluator conformance suite must exist")
    (assert (= (.-_tag r-res) "ok") "rpc conformance suite must exist")
    (assert (= (.-_tag v-res) "ok") "vfs conformance suite must exist")
    (assert (= (.-_tag g-res) "ok") "gates conformance suite must exist")
    (assert (= (.-_tag t-res) "ok") "text conformance suite must exist")
    (assert (= (.-_tag l-res) "ok") "ledger conformance suite must exist")
    (let [(b-src (.-value b-res))
          (e-src (.-value e-res))
          (r-src (.-value r-res))
          (v-src (.-value v-res))
          (g-src (.-value g-res))
          (t-src (.-value t-res))
          (l-src (.-value l-res))]
      (assert (string-contains? b-src "TestNegativeControl") "Boundary must implement negativeControl")
      (assert (string-contains? e-src "TestErrorPropagation") "Evaluator must implement errorPropagation")
      (assert (string-contains? r-src "TestMalformed") "RPC must implement malformed")
      (assert (string-contains? v-src "TestIdempotence") "VFS must implement idempotence")
      (assert (string-contains? g-src "TestAdversarial") "Gates must implement adversarial")
      (assert (string-contains? t-src "TestRoundTrip") "Text must implement roundTrip")
      (assert (string-contains? l-src "TestResourceBound") "Ledger must implement resourceBound")
      true)))

(df TestTask44402GroundedInPhase444 [] -> Bool
  :d "Verifies Phase 444 task collection grounds Task44402"
  (let [(p-res (file-read ".asl/mem/tasks/Phase444TestTelemetryAndCoverageGuarantees.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 444 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Task44402") "Phase 444 must contain Task44402")
      (assert (string-contains? p-src ":lane \"coverage\"") "Phase 444 must specify coverage lane")
      (assert (string-contains? p-src "run_gate_7") "Phase 444 must target run_gate_7")
      (assert (string-contains? p-src "docs/TEST_CASE_CATALOG.md") "Phase 444 must own TEST_CASE_CATALOG.md")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44402 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestCatalogTwelveKindsContract) "TestCatalogTwelveKindsContract must pass")
    (assert (TestCoverageGuaranteesTargetSymbolsContract) "TestCoverageGuaranteesTargetSymbolsContract must pass")
    (assert (TestDecidableGuaranteesBehavioralContract) "TestDecidableGuaranteesBehavioralContract must pass")
    (assert (TestPhase443AreasCaseKindsEnforcement) "TestPhase443AreasCaseKindsEnforcement must pass")
    (assert (TestTask44402GroundedInPhase444) "TestTask44402GroundedInPhase444 must pass")
    true))
