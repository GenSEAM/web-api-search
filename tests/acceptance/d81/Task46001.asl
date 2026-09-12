(module tests/acceptance/d81/Task46001
  :d "Acceptance fixture for Task46001: Rename core forms to Scheme spellings at zero token cost under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestSchemeCoreFormsSemanticRule
      TestTokenCompactionParityAndRejectionOfHashForms]
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

(df TestSchemeCoreFormsSemanticRule [] -> Bool
  :d "Verifies language-semantics.asn defines schemeCoreFormsAlignment semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "schemeCoreFormsAlignment") "language-semantics.asn must define schemeCoreFormsAlignment semantic")
      (assert (string-contains? s-src "ERR_RETIRED_ABBREVIATION") "language-semantics.asn must specify ERR_RETIRED_ABBREVIATION failureCode")
      true)))

(df TestTokenCompactionParityAndRejectionOfHashForms [] -> Bool
  :d "Verifies Phase 460 documents zero token delta across 21617 uses and rejects hash forms"
  (let [(p-res (file-read ".asl/mem/tasks/Phase460SchemeAlignmentAndRacketConcepts.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase460 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "zero token cost") "Phase 460 must document zero token cost")
      (assert (string-contains? p-src "21617 uses") "Phase 460 must document 21617 uses")
      (assert (string-contains? p-src "hash-t and hash-f would cost 0.43 percent and is rejected") "Phase 460 must document hash-t/hash-f rejection")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46001 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestSchemeCoreFormsSemanticRule) "TestSchemeCoreFormsSemanticRule must pass")
    (assert (TestTokenCompactionParityAndRejectionOfHashForms) "TestTokenCompactionParityAndRejectionOfHashForms must pass")
    true))
