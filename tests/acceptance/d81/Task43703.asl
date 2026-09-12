(module tests/acceptance/d81/Task43703
  :d "Acceptance fixture for Task43703: truthful Codex and Antigravity client projections under ADR-0081."
  :x [run-tests
      test-agents-md-no-legacy-orchestrator-duplicate
      test-agy-and-codex-launch-projections]
  :i [])

(df test-agents-md-no-legacy-orchestrator-duplicate [] -> Bool
  :d "Verifies that AGENTS.md does not contain the legacy duplicate ORCHESTRATOR_START block"
  (let [(res (file-read "AGENTS.md"))]
    (assert (= (.-_tag res) "ok") "AGENTS.md must exist and be readable")
    (let [(src (.-value res))]
      (assert (not (string-contains? src "<!-- ORCHESTRATOR_START -->"))
              "AGENTS.md must not contain legacy duplicate ORCHESTRATOR_START block")
      true)))

(df test-agy-and-codex-launch-projections [] -> Bool
  :d "Verifies that asl/tools/asl.c implements truthful AGY and Codex projections"
  (let [(res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":permission-tier \"dangerous-rescue\"")
              "asl.c must define dangerous-rescue tier for AGY")
      (assert (string-contains? src "--dangerously-skip-permissions")
              "asl.c must define dangerously-skip-permissions flag for AGY")
      (assert (string-contains? src ":client \"codex\"")
              "asl.c must support codex client launch")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task43703 supervisor acceptance tests"
  (do
    (assert (test-agents-md-no-legacy-orchestrator-duplicate) "test-agents-md-no-legacy-orchestrator-duplicate must pass")
    (assert (test-agy-and-codex-launch-projections) "test-agy-and-codex-launch-projections must pass")
    true))
