(module tests/acceptance/d81/Task46201
  :d "Acceptance fixture for Task46201: Lexicon selection rule governed by measured token cost under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestMeasuredTokenCostSelectionRuleContract
      TestSelectionRuleInTokenConventions
      TestTask46201GroundedInPhase462]
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

(df TestMeasuredTokenCostSelectionRuleContract [] -> Bool
  :d "Verifies language-semantics.asn defines measuredTokenCostSelectionRule semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "measuredTokenCostSelectionRule") "language-semantics.asn must define measuredTokenCostSelectionRule semantic")
      (assert (string-contains? s-src "ERR_SPECULATIVE_NAME_CHOICE") "language-semantics.asn must specify ERR_SPECULATIVE_NAME_CHOICE failureCode")
      true)))

(df TestSelectionRuleInTokenConventions [] -> Bool
  :d "Verifies TOKEN_CONVENTIONS.md documents the measured selection rule and excludes length and family uniformity"
  (let [(t-res (file-read "TOKEN_CONVENTIONS.md"))]
    (assert (= (.-_tag t-res) "ok") "TOKEN_CONVENTIONS.md must exist and be readable")
    (let [(t-src (.-value t-res))]
      (assert (string-contains? t-src "measured token count") "TOKEN_CONVENTIONS.md must mandate measured token count")
      (assert (string-contains? t-src "Length is not a criterion") "TOKEN_CONVENTIONS.md must state length is not a criterion")
      (assert (string-contains? t-src "Uniformity of a family is not a criterion") "TOKEN_CONVENTIONS.md must state family uniformity is not a criterion")
      true)))

(df TestTask46201GroundedInPhase462 [] -> Bool
  :d "Verifies Phase 462 task file grounds measured cost selection rule"
  (let [(p-res (file-read ".asl/mem/tasks/Phase462LlmFirstLexicon.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 462 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "The selection rule: measured cost decides, length and pattern do not") "Phase 462 must state task title")
      (assert (string-contains? p-src "One recorded selection rule with its measured basis") "Phase 462 must state selection rule outcome")
      (assert (string-contains? p-src "Length and family pattern explicitly excluded as criteria") "Phase 462 must state excluded criteria outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46201 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestMeasuredTokenCostSelectionRuleContract) "TestMeasuredTokenCostSelectionRuleContract must pass")
    (assert (TestSelectionRuleInTokenConventions) "TestSelectionRuleInTokenConventions must pass")
    (assert (TestTask46201GroundedInPhase462) "TestTask46201GroundedInPhase462 must pass")
    true))
