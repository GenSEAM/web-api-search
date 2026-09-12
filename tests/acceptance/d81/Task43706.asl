(module tests/acceptance/d81/Task43706
  :d "Acceptance fixture for Task43706: settle contradictory directives without performance mythology under ADR-0081."
  :x [run-tests
      test-agents-md-no-host-tool-forbid
      test-agents-md-git-coauthor-policy]
  :i [])

(df test-agents-md-no-host-tool-forbid [] -> Bool
  :d "Verifies that AGENTS.md does not contain contradictory blanket bans on host tools"
  (let [(res (file-read "AGENTS.md"))]
    (assert (= (.-_tag res) "ok") "AGENTS.md must exist and be readable")
    (let [(src (.-value res))]
      (assert (not (string-contains? src ":forbid [:view_file"))
              "AGENTS.md must not contain contradictory blanket :forbid on host tools")
      true)))

(df test-agents-md-git-coauthor-policy [] -> Bool
  :d "Verifies that AGENTS.md enforces git co-author policy without mythology"
  (let [(res (file-read "AGENTS.md"))]
    (assert (= (.-_tag res) "ok") "AGENTS.md must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":coAuthor (:claude :host :agy false)")
              "AGENTS.md must enforce settled coAuthor policy")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task43706 supervisor acceptance tests"
  (do
    (assert (test-agents-md-no-host-tool-forbid) "test-agents-md-no-host-tool-forbid must pass")
    (assert (test-agents-md-git-coauthor-policy) "test-agents-md-git-coauthor-policy must pass")
    true))
