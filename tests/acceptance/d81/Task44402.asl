(module tests/acceptance/d81/Task44402
  :d "Acceptance fixture for Task44402: Three decidable coverage guarantees, gated; mutation score as quality metric under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestDecidableCoverageGuaranteesContract
      TestMutationScoreDistinctFromCoverage
      TestTestCaseCatalogRequiredKindsContract
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

(df TestDecidableCoverageGuaranteesContract [] -> Bool
  :d "Verifies that asl/tools/asl.c and coverage telemetry enforce three decidable guarantees per package"
  (let [(c-res (file-read "asl/tools/asl.c"))
        (cat-res (file-read "docs/TEST_CASE_CATALOG.md"))]
    (assert (= (.-_tag c-res) "ok") "asl.c must exist and be readable")
    (assert (= (.-_tag cat-res) "ok") "TEST_CASE_CATALOG.md must exist and be readable")
    (let [(c-src (.-value c-res))
          (cat-src (.-value cat-res))]
      (assert (string-contains? c-src "audit_coverage") "asl.c must implement audit_coverage")
      (assert (string-contains? c-src ":symbol-coverage") "asl.c must track per-symbol coverage")
      (assert (string-contains? c-src ":case-kinds") "asl.c must report case kinds")
      (assert (string-contains? c-src "docs/TEST_CASE_CATALOG.md") "asl.c must link to TEST_CASE_CATALOG.md")
      (assert (string-contains? cat-src "The twelve kinds") "TEST_CASE_CATALOG.md must document the twelve kinds")
      (assert (string-contains? cat-src "Happy path") "TEST_CASE_CATALOG.md must include Happy path")
      (assert (string-contains? cat-src "Boundary") "TEST_CASE_CATALOG.md must include Boundary")
      (assert (string-contains? cat-src "Negative control") "TEST_CASE_CATALOG.md must include Negative control")
      true)))

(df TestMutationScoreDistinctFromCoverage [] -> Bool
  :d "Verifies mutation score is tracked as a distinct quality metric from coverage guarantees"
  (let [(c-res (file-read "asl/tools/asl.c"))
        (cap-res (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag c-res) "ok") "asl.c must exist")
    (assert (= (.-_tag cap-res) "ok") "capabilities.asn must exist")
    (let [(c-src (.-value c-res))
          (cap-src (.-value cap-res))]
      (assert (string-contains? c-src "mutationScore") "asl.c must report mutationScore capability")
      (assert (string-contains? cap-src ":cap :id mutationScore") "capabilities.asn must define mutationScore")
      (assert (string-contains? cap-src "asl test --strict-falsify reports fault-detection power") "mutationScore must report fault-detection power")
      (assert (string-contains? cap-src "Task43901") "mutationScore capability must link to Task43901")
      true)))

(df TestTestCaseCatalogRequiredKindsContract [] -> Bool
  :d "Verifies TEST_CASE_CATALOG.md requires case kinds per area and rejects kind 1 alone"
  (let [(cat-res (file-read "docs/TEST_CASE_CATALOG.md"))]
    (assert (= (.-_tag cat-res) "ok") "TEST_CASE_CATALOG.md must exist")
    (let [(cat-src (.-value cat-res))]
      (assert (string-contains? cat-src "A suite that covers only kind 1 is rejected at review") "Must explicitly reject single-kind happy path suites")
      (assert (string-contains? cat-src "Every area in Phase443 declares which kinds it needs") "Must link required kinds to Phase443 areas")
      (assert (string-contains? cat-src "One behaviour per") "Must require one behaviour per test function")
      (assert (string-contains? cat-src "Every `assert` carries a message") "Must mandate message on every assert")
      true)))

(df TestTask44402GroundedInPhase444 [] -> Bool
  :d "Verifies Phase 444 task collection grounds Task44402"
  (let [(p-res (file-read ".asl/mem/tasks/Phase444TestTelemetryAndCoverageGuarantees.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 444 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Three decidable coverage guarantees") "Phase 444 must state Task44402 title")
      (assert (string-contains? p-src ":lane \"coverage\"") "Phase 444 must specify coverage lane")
      (assert (string-contains? p-src "run_gate_7") "Phase 444 must target run_gate_7")
      (assert (string-contains? p-src "docs/TEST_CASE_CATALOG.md") "Phase 444 must own docs/TEST_CASE_CATALOG.md")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44402 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestDecidableCoverageGuaranteesContract) "TestDecidableCoverageGuaranteesContract must pass")
    (assert (TestMutationScoreDistinctFromCoverage) "TestMutationScoreDistinctFromCoverage must pass")
    (assert (TestTestCaseCatalogRequiredKindsContract) "TestTestCaseCatalogRequiredKindsContract must pass")
    (assert (TestTask44402GroundedInPhase444) "TestTask44402GroundedInPhase444 must pass")
    true))
