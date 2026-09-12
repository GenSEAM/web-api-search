(module tests/acceptance/d81/Task43702
  :d "Acceptance fixture for Task43702: minimal stable Claude launch projection under ADR-0081."
  :x [run-tests
      test-agents-md-no-legacy-toolbelt-duplicate
      test-claude-launch-projection-safe-mode]
  :i [])

(df test-agents-md-no-legacy-toolbelt-duplicate [] -> Bool
  :d "Verifies that AGENTS.md does not contain the duplicate legacy ASL_TOOLBELT_START block"
  (let [(res (file-read "AGENTS.md"))]
    (assert (= (.-_tag res) "ok") "AGENTS.md must exist and be readable")
    (let [(src (.-value res))]
      (assert (not (string-contains? src "<!-- ASL_TOOLBELT_START -->"))
              "AGENTS.md must not contain legacy duplicate ASL_TOOLBELT_START block")
      true)))

(df test-claude-launch-projection-safe-mode [] -> Bool
  :d "Verifies that asl/tools/asl.c enforces system-guided safe permissions for claude launch"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src "Stripped dangerous permissions for Claude Code")
              "asl.c must strip dangerous permissions for Claude Code")
      (assert (string-contains? src ":claude-mode \"system-guided\"")
              "asl.c must enforce system-guided mode for Claude Code")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task43702 supervisor acceptance tests"
  (do
    (assert (test-agents-md-no-legacy-toolbelt-duplicate) "test-agents-md-no-legacy-toolbelt-duplicate must pass")
    (assert (test-claude-launch-projection-safe-mode) "test-claude-launch-projection-safe-mode must pass")
    true))
