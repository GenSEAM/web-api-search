(module tests/acceptance/d81/Task46702
  :d "Acceptance fixture for Task46702: scenario matrix per tool testing edge conditions under ADR-0081."
  :x [run-tests
      test-tool-scenarios-suite-exists
      test-scenario-matrix-edge-cases]
  :i [])

(df test-tool-scenarios-suite-exists [] -> Bool
  :d "Verifies that tests/probes/tool_scenarios_test.asl exists and is readable"
  (let [(res (file-read "tests/probes/tool_scenarios_test.asl"))]
    (assert (= (.-_tag res) "ok") "tests/probes/tool_scenarios_test.asl must exist and be readable")
    true))

(df test-scenario-matrix-edge-cases [] -> Bool
  :d "Verifies that tool_scenarios_test.asl covers edge conditions (nonexistent file, traversal, empty query)"
  (let [(res (file-read "tests/probes/tool_scenarios_test.asl"))]
    (assert (= (.-_tag res) "ok") "tool_scenarios_test.asl must exist")
    (let [(src (.-value res))]
      (assert (string-contains? src "test-missing-file") "tool scenarios must test missing file")
      (assert (string-contains? src "test-path-traversal") "tool scenarios must test path traversal")
      (assert (string-contains? src "test-bounded-output") "tool scenarios must test bounded output")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task46702 supervisor acceptance tests"
  (do
    (assert (test-tool-scenarios-suite-exists) "test-tool-scenarios-suite-exists must pass")
    (assert (test-scenario-matrix-edge-cases) "test-scenario-matrix-edge-cases must pass")
    true))
