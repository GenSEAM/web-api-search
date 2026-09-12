(module tests/acceptance/d81/Task44502
  :d "Acceptance fixture for Task44502: Static checkers for unconfirmed rules under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestRuleCheckersModuleContract
      TestRuleCheckersManifestAndGrammarContract
      TestDecidableRuleCheckersBehaviorContract
      TestRuntimeOnlyRulesReasonContract
      TestTask44502GroundedInPhase445]
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

(df TestRuleCheckersModuleContract [] -> Bool
  :d "Verifies asl/packages/asl-gates/src/rule_checkers.asl defines decidable rule audit contracts"
  (let [(m-res (file-read "asl/packages/asl-gates/src/rule_checkers.asl"))]
    (assert (= (.-_tag m-res) "ok") "rule_checkers.asl must exist and be readable")
    (let [(m-src (.-value m-res))]
      (assert (string-contains? m-src "asl-gates/rule-checkers") "Must declare module asl-gates/rule-checkers")
      (assert (string-contains? m-src "RuleCheckResult") "Must export RuleCheckResult")
      (assert (string-contains? m-src "audit-grading-rule") "Must export audit-grading-rule")
      (assert (string-contains? m-src "audit-concepts-rule") "Must export audit-concepts-rule")
      (assert (string-contains? m-src "audit-ownership-disjointness") "Must export audit-ownership-disjointness")
      (assert (string-contains? m-src "audit-hidden-tests-rule") "Must export audit-hidden-tests-rule")
      (assert (string-contains? m-src "audit-bounded-rule") "Must export audit-bounded-rule")
      (assert (string-contains? m-src "audit-output-rule") "Must export audit-output-rule")
      (assert (string-contains? m-src "audit-runtime-only-rules") "Must export audit-runtime-only-rules")
      true)))

(df TestRuleCheckersManifestAndGrammarContract [] -> Bool
  :d "Verifies manifest.asn and grammar.asn register rule-checkers module and symbols"
  (let [(man-res (file-read "asl/packages/asl-gates/manifest.asn"))
        (gram-res (file-read "asl/packages/asl-gates/grammar.asn"))]
    (assert (= (.-_tag man-res) "ok") "asl-gates/manifest.asn must exist and be readable")
    (assert (= (.-_tag gram-res) "ok") "asl-gates/grammar.asn must exist and be readable")
    (let [(man-src (.-value man-res))
          (gram-src (.-value gram-res))]
      (assert (string-contains? man-src "asl-gates/rule-checkers") "manifest must register rule-checkers")
      (assert (string-contains? gram-src ":name \"RuleCheckResult\"") "grammar must register RuleCheckResult")
      (assert (string-contains? gram-src ":name \"audit-grading-rule\"") "grammar must register audit-grading-rule")
      (assert (string-contains? gram-src ":name \"audit-concepts-rule\"") "grammar must register audit-concepts-rule")
      (assert (string-contains? gram-src ":name \"audit-hidden-tests-rule\"") "grammar must register audit-hidden-tests-rule")
      (assert (string-contains? gram-src ":name \"audit-runtime-only-rules\"") "grammar must register audit-runtime-only-rules")
      true)))

(df TestDecidableRuleCheckersBehaviorContract [] -> Bool
  :d "Verifies rule checkers implementation logic across grading, concepts, and hidden tests"
  (let [(m-res (file-read "asl/packages/asl-gates/src/rule_checkers.asl"))]
    (assert (= (.-_tag m-res) "ok") "rule_checkers.asl must exist and be readable")
    (let [(m-src (.-value m-res))]
      (assert (string-contains? m-src "author cannot grade its own work") "Must report author grading violation")
      (assert (string-contains? m-src "author paths intersect verifier paths") "Must report path overlap violation")
      (assert (string-contains? m-src "concept claim cites nonexistent source") "Must report ungrounded citation")
      (assert (string-contains? m-src "implementer cannot own grader acceptance tests") "Must report hidden tests violation")
      (assert (string-contains? m-src "read call site missing :limit") "Must report unbounded read violation")
      (assert (string-contains? m-src "receipt missing path or line") "Must report output receipt violation")
      true)))

(df TestRuntimeOnlyRulesReasonContract [] -> Bool
  :d "Verifies budget and edge rules declare explicit runtimeOnlyReason in rules.asn"
  (let [(r-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag r-res) "ok") "rules.asn must exist and be readable")
    (let [(r-src (.-value r-res))]
      (assert (string-contains? r-src ":id budget") "rules.asn must define budget rule")
      (assert (string-contains? r-src ":id edge") "rules.asn must define edge rule")
      (assert (string-contains? r-src "Tool call budget and observation compaction") "budget rule must declare reason")
      (assert (string-contains? r-src "Dynamic unplanned contingency escalation") "edge rule must declare reason")
      true)))

(df TestTask44502GroundedInPhase445 [] -> Bool
  :d "Verifies Phase 445 task collection grounds Task44502"
  (let [(p-res (file-read ".asl/mem/tasks/Phase445StaticConfirmationCoverage.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 445 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Static checkers for the eleven unconfirmed rules") "Phase 445 must state Task44502 title")
      (assert (string-contains? p-src "One checker per decidable rule") "Phase 445 must state checker outcome")
      (assert (string-contains? p-src "budget and edge declared runtime-only with a reason") "Phase 445 must state runtime-only outcome")
      (assert (string-contains? p-src "All checkers reachable from asl doctor and gate 7") "Phase 445 must state reachability outcome")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44502 acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestRuleCheckersModuleContract) "TestRuleCheckersModuleContract must pass")
    (assert (TestRuleCheckersManifestAndGrammarContract) "TestRuleCheckersManifestAndGrammarContract must pass")
    (assert (TestDecidableRuleCheckersBehaviorContract) "TestDecidableRuleCheckersBehaviorContract must pass")
    (assert (TestRuntimeOnlyRulesReasonContract) "TestRuntimeOnlyRulesReasonContract must pass")
    (assert (TestTask44502GroundedInPhase445) "TestTask44502GroundedInPhase445 must pass")
    true))
