(module tests/acceptance/d81/Task46202
  :d "Acceptance fixture for Task46202: No symbol enters the language unmeasured under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestSymbolAdmissionMeasuredCostContract
      TestSymbolAdmissionRequirementsInGrammar
      TestTask46202GroundedInPhase462]
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

(df TestSymbolAdmissionMeasuredCostContract [] -> Bool
  :d "Verifies language-semantics.asn defines symbolAdmissionMeasuredCostRule semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "symbolAdmissionMeasuredCostRule") "language-semantics.asn must define symbolAdmissionMeasuredCostRule semantic")
      (assert (string-contains? s-src "ERR_UNMEASURED_SYMBOL_ADMISSION") "language-semantics.asn must specify ERR_UNMEASURED_SYMBOL_ADMISSION failureCode")
      true)))

(df TestSymbolAdmissionRequirementsInGrammar [] -> Bool
  :d "Verifies grammar.asn mandates measured token cost and alternative recording for symbol admission"
  (let [(g-res (file-read "asl/grammar/grammar.asn"))]
    (assert (= (.-_tag g-res) "ok") "grammar.asn must exist and be readable")
    (let [(g-src (.-value g-res))]
      (assert (string-contains? g-src ":tokens") "grammar.asn must mandate :tokens measurement")
      (assert (string-contains? g-src ":rationale") "grammar.asn must mandate :rationale")
      true)))

(df TestTask46202GroundedInPhase462 [] -> Bool
  :d "Verifies Phase 462 task file grounds unmeasured symbol exclusion"
  (let [(p-res (file-read ".asl/mem/tasks/Phase462LlmFirstLexicon.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 462 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "No symbol enters the language unmeasured") "Phase 462 must state task title")
      (assert (string-contains? p-src "Measured cost recorded per symbol at admission") "Phase 462 must state measured cost outcome")
      (assert (string-contains? p-src "Counts recomputed by the checker, never trusted") "Phase 462 must state recomputation outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46202 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestSymbolAdmissionMeasuredCostContract) "TestSymbolAdmissionMeasuredCostContract must pass")
    (assert (TestSymbolAdmissionRequirementsInGrammar) "TestSymbolAdmissionRequirementsInGrammar must pass")
    (assert (TestTask46202GroundedInPhase462) "TestTask46202GroundedInPhase462 must pass")
    true))
