(module tests/acceptance/d81/Task46004
  :d "Acceptance fixture for Task46004: Source location tracking via syntax objects under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestSyntaxObjectSourceLocationContract
      TestDualPositionDiagnosticContract
      TestSyntaxPositionPreservationContract
      TestEngineSourceLocationPreservation]
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

(df TestSyntaxObjectSourceLocationContract [] -> Bool
  :d "Verifies language-semantics.asn defines syntaxObjectSourceLocation semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "syntaxObjectSourceLocation") "language-semantics.asn must define syntaxObjectSourceLocation semantic")
      (assert (string-contains? s-src "ERR_MISSING_SOURCE_LOCATION") "language-semantics.asn must specify ERR_MISSING_SOURCE_LOCATION failureCode")
      true)))

(df TestDualPositionDiagnosticContract [] -> Bool
  :d "Verifies language-semantics.asn defines dualPositionDiagnostic semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "dualPositionDiagnostic") "language-semantics.asn must define dualPositionDiagnostic semantic")
      (assert (string-contains? s-src "ERR_TRUNCATED_ERROR_SITE") "language-semantics.asn must specify ERR_TRUNCATED_ERROR_SITE failureCode")
      true)))

(df TestSyntaxPositionPreservationContract [] -> Bool
  :d "Verifies language-semantics.asn defines syntaxPositionPreservation semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "syntaxPositionPreservation") "language-semantics.asn must define syntaxPositionPreservation semantic")
      (assert (string-contains? s-src "ERR_SYNTAX_POSITION_LOST") "language-semantics.asn must specify ERR_SYNTAX_POSITION_LOST failureCode")
      true)))

(df TestEngineSourceLocationPreservation [] -> Bool
  :d "Verifies asl/tools/engine.js parses and preserves source, line, and col metadata"
  (let [(e-res (file-read "asl/tools/engine.js"))]
    (assert (= (.-_tag e-res) "ok") "asl/tools/engine.js must exist and be readable")
    (let [(e-src (.-value e-res))]
      (assert (string-contains? e-src "getCol") "engine.js must calculate column offset")
      (assert (string-contains? e-src "sourcePath") "engine.js parseAllSExprs must accept sourcePath")
      (assert (string-contains? e-src "span") "engine.js AST nodes must preserve span metadata")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46004 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestSyntaxObjectSourceLocationContract) "TestSyntaxObjectSourceLocationContract must pass")
    (assert (TestDualPositionDiagnosticContract) "TestDualPositionDiagnosticContract must pass")
    (assert (TestSyntaxPositionPreservationContract) "TestSyntaxPositionPreservationContract must pass")
    (assert (TestEngineSourceLocationPreservation) "TestEngineSourceLocationPreservation must pass")
    true))
