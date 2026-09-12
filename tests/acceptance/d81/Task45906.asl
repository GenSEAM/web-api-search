(module tests/acceptance/d81/Task45906
  :d "Acceptance fixture for Task45906: Correct D51 claim to its measured scope under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestGroundedNumericClaimsContract
      TestDualScopeCompactionReportContract
      TestTokenConventionsMeasuredScope
      TestAgentsMdMeasuredScope
      TestRulesAsnMeasuredScope]
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

(df TestGroundedNumericClaimsContract [] -> Bool
  :d "Verifies language-semantics.asn defines groundedNumericClaims semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "groundedNumericClaims") "language-semantics.asn must define groundedNumericClaims semantic")
      (assert (string-contains? s-src "ERR_UNGROUNDED_NUMERIC_CLAIM") "language-semantics.asn must specify ERR_UNGROUNDED_NUMERIC_CLAIM failureCode")
      true)))

(df TestDualScopeCompactionReportContract [] -> Bool
  :d "Verifies language-semantics.asn defines dualScopeCompactionReport semantic"
  (let [(s-res (file-read "asl/grammar/language-semantics.asn"))]
    (assert (= (.-_tag s-res) "ok") "language-semantics.asn must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "dualScopeCompactionReport") "language-semantics.asn must define dualScopeCompactionReport semantic")
      (assert (string-contains? s-src "ERR_PARTIAL_SCOPE_CLAIM") "language-semantics.asn must specify ERR_PARTIAL_SCOPE_CLAIM failureCode")
      true)))

(df TestTokenConventionsMeasuredScope [] -> Bool
  :d "Verifies TOKEN_CONVENTIONS.md states per-identifier 44 to 50 percent, corpus-wide 3.06 percent on 888 files under cl100k"
  (let [(t-res (file-read "TOKEN_CONVENTIONS.md"))]
    (assert (= (.-_tag t-res) "ok") "TOKEN_CONVENTIONS.md must exist and be readable")
    (let [(t-src (.-value t-res))]
      (assert (string-contains? t-src "3.06 percent") "TOKEN_CONVENTIONS.md must document 3.06 percent corpus-wide saving")
      (assert (string-contains? t-src "44 to 50 percent") "TOKEN_CONVENTIONS.md must document 44 to 50 percent per long identifier")
      (assert (string-contains? t-src "888 files") "TOKEN_CONVENTIONS.md must specify 888 files scope")
      (assert (string-contains? t-src "cl100k") "TOKEN_CONVENTIONS.md must specify cl100k tokenizer")
      true)))

(df TestAgentsMdMeasuredScope [] -> Bool
  :d "Verifies AGENTS.md documents measured dual scope for CamelCase conventions"
  (let [(a-res (file-read "AGENTS.md"))]
    (assert (= (.-_tag a-res) "ok") "AGENTS.md must exist and be readable")
    (let [(a-src (.-value a-res))]
      (assert (string-contains? a-src "3.06%") "AGENTS.md must document 3.06% corpus-wide saving")
      (assert (string-contains? a-src "44% to 50%") "AGENTS.md must document 44% to 50% per long identifier")
      true)))

(df TestRulesAsnMeasuredScope [] -> Bool
  :d "Verifies asl/grammar/rules.asn records measured scope for names heuristic"
  (let [(r-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag r-res) "ok") "rules.asn must exist and be readable")
    (let [(r-src (.-value r-res))]
      (assert (string-contains? r-src "3.06%") "rules.asn names rule must document 3.06% corpus-wide figure")
      (assert (string-contains? r-src "44-50%") "rules.asn names rule must document 44-50% per long identifier")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task45906 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestGroundedNumericClaimsContract) "TestGroundedNumericClaimsContract must pass")
    (assert (TestDualScopeCompactionReportContract) "TestDualScopeCompactionReportContract must pass")
    (assert (TestTokenConventionsMeasuredScope) "TestTokenConventionsMeasuredScope must pass")
    (assert (TestAgentsMdMeasuredScope) "TestAgentsMdMeasuredScope must pass")
    (assert (TestRulesAsnMeasuredScope) "TestRulesAsnMeasuredScope must pass")
    true))
