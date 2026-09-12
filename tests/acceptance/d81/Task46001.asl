(module tests/acceptance/d81/Task46001
  :d "Acceptance fixture for Task46001: Rename core forms to Scheme spellings at zero token cost under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestSchemeCoreFormsAlignmentContract
      TestZeroCostAbbreviationRetirementContract
      TestSchemeCoreFormsGroundedInPhase460]
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

(df TestSchemeCoreFormsAlignmentContract [] -> Bool
  :d "Verifies language-semantics.asn defines schemeCoreFormsAlignment semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "schemeCoreFormsAlignment") "language-semantics.asn must define schemeCoreFormsAlignment semantic")
      (assert (string-contains? s-src "ERR_RETIRED_ABBREVIATED_FORM") "language-semantics.asn must specify ERR_RETIRED_ABBREVIATED_FORM failureCode")
      true)))

(df TestZeroCostAbbreviationRetirementContract [] -> Bool
  :d "Verifies language-semantics.asn defines zeroCostAbbreviationRetirement semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "zeroCostAbbreviationRetirement") "language-semantics.asn must define zeroCostAbbreviationRetirement semantic")
      (assert (string-contains? s-src "ERR_ABBREVIATION_ALIAS_FORBIDDEN") "language-semantics.asn must specify ERR_ABBREVIATION_ALIAS_FORBIDDEN failureCode")
      true)))

(df TestSchemeCoreFormsGroundedInPhase460 [] -> Bool
  :d "Verifies Phase 460 task file records 16041 uses and zero token delta"
  (let [(p-res (file-read ".asl/mem/tasks/Phase460SchemeAlignmentAndRacketConcepts.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 460 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "16041") "Phase 460 must document 16041 uses")
      (assert (string-contains? p-src "zero tokens") "Phase 460 must document zero token delta")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46001 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestSchemeCoreFormsAlignmentContract) "TestSchemeCoreFormsAlignmentContract must pass")
    (assert (TestZeroCostAbbreviationRetirementContract) "TestZeroCostAbbreviationRetirementContract must pass")
    (assert (TestSchemeCoreFormsGroundedInPhase460) "TestSchemeCoreFormsGroundedInPhase460 must pass")
    true))
