(module tests/acceptance/d81/Task44102
  :d "Acceptance fixture for Task44102: Deliver applicable rules without changing the stable prefix under ADR-0081."
  :x [RunTests
      TestCanonicalRulesGrammarSource
      TestTierSlicingViaInstallScript
      TestWhenStepScopeFiltering
      TestStablePrefixPreservation]
  :i [])

(df TestCanonicalRulesGrammarSource [] -> Bool
  :d "Verifies rules.asn is the single source of truth declaring tiers and when scopes"
  (let [(r-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag r-res) "ok") "asl/grammar/rules.asn must exist and be readable")
    (let [(src (.-value r-res))]
      (assert (string-contains? src ":tiers [") "Must declare :tiers")
      (assert (string-contains? src ":when [") "Must declare :when")
      (assert (string-contains? src ":rule :id semantics") "Must declare semantics rule")
      (assert (string-contains? src ":rule :id gates") "Must declare gates rule")
      (assert (string-contains? src ":rule :id grading") "Must declare grading rule")
      (assert (string-contains? src ":rule :id ssot") "Must declare ssot rule")
      (assert (string-contains? src ":rule :id capabilities") "Must declare capabilities rule")
      true)))

(df TestTierSlicingViaInstallScript [] -> Bool
  :d "Verifies scripts/install.sh implements tier extraction and rule consistency check"
  (let [(s-res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag s-res) "ok") "scripts/install.sh must exist")
    (let [(src (.-value s-res))]
      (assert (string-contains? src "--tier") "install.sh must support --tier")
      (assert (string-contains? src "--render-rules") "install.sh must support --render-rules")
      (assert (string-contains? src "--check-rules") "install.sh must support --check-rules")
      true)))

(df TestWhenStepScopeFiltering [] -> Bool
  :d "Verifies that rules declare appropriate when step-scopes"
  (let [(r-res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag r-res) "ok") "rules.asn must exist")
    (let [(src (.-value r-res))]
      (assert (string-contains? src ":when [:implement :grade]") "Must declare implement/grade scope")
      (assert (string-contains? src ":when [:scout :implement]") "Must declare scout/implement scope")
      (assert (string-contains? src ":when [:all]") "Must declare all scope")
      true)))

(df TestStablePrefixPreservation [] -> Bool
  :d "Verifies that exported surfaces preserve the stable rule prefix"
  (let [(a-res (file-read "AGENTS.md"))
        (s-res (file-read ".agents/skills/asl-toolbelt/SKILL.md"))]
    (assert (= (.-_tag a-res) "ok") "AGENTS.md must exist")
    (assert (= (.-_tag s-res) "ok") "asl-toolbelt/SKILL.md must exist")
    (let [(a-src (.-value a-res))
          (s-src (.-value s-res))]
      (assert (string-contains? a-src "<!-- ASL_RULES_START -->") "AGENTS.md must define ASL_RULES_START")
      (assert (string-contains? a-src "<!-- ASL_RULES_END -->") "AGENTS.md must define ASL_RULES_END")
      (assert (string-contains? s-src "## Rules") "SKILL.md must contain Rules section")
      (assert (string-contains? s-src "(:rules :v 7") "SKILL.md must contain canonical rules")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44102 supervisor acceptance tests"
  (do
    (assert (TestCanonicalRulesGrammarSource) "TestCanonicalRulesGrammarSource must pass")
    (assert (TestTierSlicingViaInstallScript) "TestTierSlicingViaInstallScript must pass")
    (assert (TestWhenStepScopeFiltering) "TestWhenStepScopeFiltering must pass")
    (assert (TestStablePrefixPreservation) "TestStablePrefixPreservation must pass")
    true))
