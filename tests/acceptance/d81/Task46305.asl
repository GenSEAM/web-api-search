(module tests/acceptance/d81/Task46305
  :d "Acceptance fixture for Task46305: Record refuted structural rewrites and explicit delimiter optimality under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestRefutedStructuralRewritesRuleContract
      TestRefutedRewritesInTokenConventions
      TestRefutedRewritesInPrinciplesLedger
      TestTask46305GroundedInPhase463]
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

(df TestRefutedStructuralRewritesRuleContract [] -> Bool
  :d "Verifies language-semantics.asn defines refutedStructuralRewritesRule semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "refutedStructuralRewritesRule") "language-semantics.asn must define refutedStructuralRewritesRule semantic")
      (assert (or (string-contains? s-src "ERR_REOPENING_REFUTED_REWRITE_WITHOUT_MEASUREMENT") (string-contains? s-src "ERR_REOPENED_REFUTED_REWRITE")) "language-semantics.asn must specify failureCode")
      true)))

(df TestRefutedRewritesInTokenConventions [] -> Bool
  :d "Verifies TOKEN_CONVENTIONS.md records the three refuted structural rewrites and explicit delimiter optimality"
  (let [(t-res (file-read "TOKEN_CONVENTIONS.md"))]
    (assert (= (.-_tag t-res) "ok") "TOKEN_CONVENTIONS.md must exist and be readable")
    (let [(t-src (.-value t-res))]
      (assert (string-contains? t-src "devowelling") "TOKEN_CONVENTIONS.md must document devowelling refutation")
      (assert (string-contains? t-src "106") "TOKEN_CONVENTIONS.md must document 106 percent devowelling cost rise")
      (assert (string-contains? t-src "delimiter deletion") "TOKEN_CONVENTIONS.md must document delimiter deletion refutation")
      (assert (string-contains? t-src "indentation-significant") "TOKEN_CONVENTIONS.md must document indentation-significant refutation")
      (assert (or (string-contains? t-src "explicit delimiters") (string-contains? t-src "Explicit delimiters")) "TOKEN_CONVENTIONS.md must document explicit delimiters as optimal")
      true)))

(df TestRefutedRewritesInPrinciplesLedger [] -> Bool
  :d "Verifies principles.asn records the refuted rewrites principle with measurements"
  (let [(p-res (file-read ".asl/mem/principles.asn"))]
    (assert (= (.-_tag p-res) "ok") "principles.asn must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "RefutedStructuralRewrites") "principles.asn must record RefutedStructuralRewrites principle")
      (assert (string-contains? p-src "devowelling") "principles.asn must document devowelling in refutations")
      (assert (or (string-contains? p-src "explicit delimiters") (string-contains? p-src "Explicit delimiters")) "principles.asn must document explicit delimiters surviving conclusion")
      true)))

(df TestTask46305GroundedInPhase463 [] -> Bool
  :d "Verifies Phase 463 task file grounds refuted structural rewrites"
  (let [(p-res (file-read ".asl/mem/tasks/Phase463AslFirstBeyondRacket.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 463 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Record the refuted rewrites so they do not return") "Phase 463 must state task title")
      (assert (string-contains? p-src "Three refutations recorded with method and number") "Phase 463 must state three refutations outcome")
      (assert (string-contains? p-src "The surviving conclusion recorded with its scope") "Phase 463 must state surviving conclusion outcome")
      (assert (string-contains? p-src "Reopening requires measurement") "Phase 463 must state reopening requirement outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task46305 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestRefutedStructuralRewritesRuleContract) "TestRefutedStructuralRewritesRuleContract must pass")
    (assert (TestRefutedRewritesInTokenConventions) "TestRefutedRewritesInTokenConventions must pass")
    (assert (TestRefutedRewritesInPrinciplesLedger) "TestRefutedRewritesInPrinciplesLedger must pass")
    (assert (TestTask46305GroundedInPhase463) "TestTask46305GroundedInPhase463 must pass")
    true))
