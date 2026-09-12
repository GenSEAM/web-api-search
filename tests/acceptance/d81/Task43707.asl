(module tests/acceptance/d81/Task43707
  :d "Acceptance fixture for Task43707: settle all reviewed rules in one canonical generated source under ADR-0081."
  :x [run-tests
      test-rules-canonical-source-intact
      test-agents-md-pure-projection-no-drift]
  :i [])

(df test-rules-canonical-source-intact [] -> Bool
  :d "Verifies that asl/grammar/rules.asn is intact with settled rules"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/rules.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "(:rule :id ssot") "rules.asn must define ssot rule")
      (assert (string-contains? src "(:rule :id tools") "rules.asn must define tools rule")
      (assert (string-contains? src "(:rule :id capabilities") "rules.asn must define capabilities rule")
      true)))

(df test-agents-md-pure-projection-no-drift [] -> Bool
  :d "Verifies that AGENTS.md contains no unmanaged duplicate legacy blocks after ASL_RULES_END"
  (let [(res (file-read "AGENTS.md"))]
    (assert (= (.-_tag res) "ok") "AGENTS.md must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "<!-- ASL_RULES_START -->") "AGENTS.md must have ASL_RULES_START")
      (assert (string-contains? src "<!-- ASL_RULES_END -->") "AGENTS.md must have ASL_RULES_END")
      (assert (not (string-contains? src "<!-- ASL_TOOLBELT_START -->"))
              "AGENTS.md must not retain legacy unmanaged ASL_TOOLBELT_START block")
      (assert (not (string-contains? src "<!-- ORCHESTRATOR_START -->"))
              "AGENTS.md must not retain legacy unmanaged ORCHESTRATOR_START block")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task43707 supervisor acceptance tests"
  (do
    (assert (test-rules-canonical-source-intact) "test-rules-canonical-source-intact must pass")
    (assert (test-agents-md-pure-projection-no-drift) "test-agents-md-pure-projection-no-drift must pass")
    true))
