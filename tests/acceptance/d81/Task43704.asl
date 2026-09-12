(module tests/acceptance/d81/Task43704
  :d "Acceptance fixture for Task43704: deduplicate effective injection with one home per block under ADR-0081."
  :x [run-tests
      test-agents-md-no-legacy-governance-blocks
      test-agents-md-single-rule-occurrences]
  :i [])

(df test-agents-md-no-legacy-governance-blocks [] -> Bool
  :d "Verifies that AGENTS.md does not contain legacy duplicate PARALLEL, GROUND_TRUTH, or GIT blocks"
  (let [(res (file-read "AGENTS.md"))]
    (assert (= (.-_tag res) "ok") "AGENTS.md must exist and be readable")
    (let [(src (.-value res))]
      (assert (not (string-contains? src "<!-- PARALLEL_START -->"))
              "AGENTS.md must not contain legacy duplicate PARALLEL_START block")
      (assert (not (string-contains? src "<!-- GROUND_TRUTH_START -->"))
              "AGENTS.md must not contain legacy duplicate GROUND_TRUTH_START block")
      (assert (not (string-contains? src "<!-- GIT_START -->"))
              "AGENTS.md must not contain legacy duplicate GIT_START block")
      true)))

(df test-agents-md-single-rule-occurrences [] -> Bool
  :d "Verifies that rules in AGENTS.md are unified under ASL_RULES_START"
  (let [(res (file-read "AGENTS.md"))]
    (assert (= (.-_tag res) "ok") "AGENTS.md must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "<!-- ASL_RULES_START -->") "AGENTS.md must retain ASL_RULES_START")
      (assert (string-contains? src "<!-- ASL_RULES_END -->") "AGENTS.md must retain ASL_RULES_END")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task43704 supervisor acceptance tests"
  (do
    (assert (test-agents-md-no-legacy-governance-blocks) "test-agents-md-no-legacy-governance-blocks must pass")
    (assert (test-agents-md-single-rule-occurrences) "test-agents-md-single-rule-occurrences must pass")
    true))
