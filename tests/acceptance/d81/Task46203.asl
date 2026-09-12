(module tests/acceptance/d81/Task46203
  :d "Acceptance fixture for Task46203: Close measured excess in the existing lexicon under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestClosedSetSingleTokenKeywordContract
      TestLexiconInventoryAndResidueTracking
      TestTask46203GroundedInPhase462]
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

(df TestClosedSetSingleTokenKeywordContract [] -> Bool
  :d "Verifies language-semantics.asn defines closedSetSingleTokenKeywordRule semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "closedSetSingleTokenKeywordRule") "language-semantics.asn must define closedSetSingleTokenKeywordRule semantic")
      (assert (string-contains? s-src "ERR_MULTI_TOKEN_CLOSED_KEYWORD") "language-semantics.asn must specify ERR_MULTI_TOKEN_CLOSED_KEYWORD failureCode")
      true)))

(df TestLexiconInventoryAndResidueTracking [] -> Bool
  :d "Verifies Phase 462 task file grounds closed set and open set minimization outcomes"
  (let [(p-res (file-read ".asl/mem/tasks/Phase462LlmFirstLexicon.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 462 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "The closed set at one token throughout") "Phase 462 must specify closed set outcome")
      (assert (string-contains? p-src "The open set at its measured minimum spelling") "Phase 462 must specify open set outcome")
      (assert (string-contains? p-src "The irreducible residue named and justified") "Phase 462 must specify residue outcome")
      true)))

(df TestTask46203GroundedInPhase462 [] -> Bool
  :d "Verifies Phase 462 task file grounds lexicon excess remediation"
  (let [(p-res (file-read ".asl/mem/tasks/Phase462LlmFirstLexicon.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 462 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Close the measured excess in the existing lexicon") "Phase 462 must state task title")
      (assert (string-contains? p-src "Lexicon total tracked in the inventory") "Phase 462 must state inventory tracking outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46203 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestClosedSetSingleTokenKeywordContract) "TestClosedSetSingleTokenKeywordContract must pass")
    (assert (TestLexiconInventoryAndResidueTracking) "TestLexiconInventoryAndResidueTracking must pass")
    (assert (TestTask46203GroundedInPhase462) "TestTask46203GroundedInPhase462 must pass")
    true))
