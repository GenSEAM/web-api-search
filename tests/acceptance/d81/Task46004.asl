(module tests/acceptance/d81/Task46004
  :d "Acceptance fixture for Task46004: Every form carries its source location as a syntax object under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestSourceLocationPreservationContract
      TestDiagnosticPositionQuotingContract
      TestSourceLocationGroundedInPhase460]
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

(df TestSourceLocationPreservationContract [] -> Bool
  :d "Verifies language-semantics.asn defines sourceLocationPreservation semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "sourceLocationPreservation") "language-semantics.asn must define sourceLocationPreservation semantic")
      (assert (string-contains? s-src "ERR_SOURCE_LOCATION_MISSING") "language-semantics.asn must specify ERR_SOURCE_LOCATION_MISSING failureCode")
      true)))

(df TestDiagnosticPositionQuotingContract [] -> Bool
  :d "Verifies language-semantics.asn defines diagnosticPositionQuoting semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "diagnosticPositionQuoting") "language-semantics.asn must define diagnosticPositionQuoting semantic")
      (assert (string-contains? s-src "ERR_UNLOCATED_DIAGNOSTIC") "language-semantics.asn must specify ERR_UNLOCATED_DIAGNOSTIC failureCode")
      true)))

(df TestSourceLocationGroundedInPhase460 [] -> Bool
  :d "Verifies Phase 460 task file grounds syntax objects and source location diagnostics"
  (let [(p-res (file-read ".asl/mem/tasks/Phase460SchemeAlignmentAndRacketConcepts.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 460 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "syntax object") "Phase 460 must reference syntax objects")
      (assert (string-contains? p-src "source, line, column and span") "Phase 460 must specify location components")
      (assert (string-contains? p-src "52 of 136 failing suites") "Phase 460 must ground measured failure counts")
      (assert (string-contains? p-src "Task45402") "Phase 460 must reference Task45402")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46004 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestSourceLocationPreservationContract) "TestSourceLocationPreservationContract must pass")
    (assert (TestDiagnosticPositionQuotingContract) "TestDiagnosticPositionQuotingContract must pass")
    (assert (TestSourceLocationGroundedInPhase460) "TestSourceLocationGroundedInPhase460 must pass")
    true))
