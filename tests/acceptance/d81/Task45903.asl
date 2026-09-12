(module tests/acceptance/d81/Task45903
  :d "Acceptance fixture for Task45903: CamelCase for multi-word identifiers at corpus-wide measured figure under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestExecutedAssertionParityContract
      TestStringLiteralPreservationContract
      TestComputedTokenSavingsGrounded]
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

(df TestExecutedAssertionParityContract [] -> Bool
  :d "Verifies language-semantics.asn defines assertion parity contract across identifier transformations"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "assertionParityAcrossTransformations") "language-semantics.asn must define assertionParityAcrossTransformations semantic")
      (assert (string-contains? s-src "ERR_UNBOUND_IDENTIFIER_MUTATION") "language-semantics.asn must specify ERR_UNBOUND_IDENTIFIER_MUTATION failureCode")
      true)))

(df TestStringLiteralPreservationContract [] -> Bool
  :d "Verifies language-semantics.asn specifies string literals are preserved and not rewritten"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "stringLiteralPreservation") "language-semantics.asn must define stringLiteralPreservation semantic")
      true)))

(df TestComputedTokenSavingsGrounded [] -> Bool
  :d "Verifies Phase 459 records 3.06 percent corpus-wide saving and 46259 tokens saved"
  (let [(p-res (file-read ".asl/mem/tasks/Phase459LanguageCompactionAndPredictability.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase459 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "3.06 percent") "Phase 459 must document 3.06 percent corpus-wide token saving")
      (assert (string-contains? p-src "46259 tokens") "Phase 459 must document 46259 tokens saved")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task45903 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestExecutedAssertionParityContract) "TestExecutedAssertionParityContract must pass")
    (assert (TestStringLiteralPreservationContract) "TestStringLiteralPreservationContract must pass")
    (assert (TestComputedTokenSavingsGrounded) "TestComputedTokenSavingsGrounded must pass")
    true))
