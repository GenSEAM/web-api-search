(module tests/acceptance/d81/Task46905
  :d "Acceptance fixture for Task46905: repair the four swarm suites to execute with non-zero assertions."
  :x [RunTests
      TestToolPlaneSuiteRepaired
      TestBrowserBridgeSuiteRepaired
      TestMeshOrchestrationSuiteHealthy
      TestGatewaySuiteHealthy]
  :i [])

(df TestToolPlaneSuiteRepaired [] -> Bool
  :d "Verifies that agent-bus/tests/tool_plane_test.asl compiles with valid canonical imports and assertions"
  (let [(res (file-read "agent-bus/tests/tool_plane_test.asl"))]
    (assert (= (.-_tag res) "ok") "agent-bus/tests/tool_plane_test.asl must exist and be readable")
    (let [(src (.-value res))
          (assert-count (list-length (string-split src "(assert")))]
      (assert (> (string-length src) 0) "tool_plane_test.asl must not be empty")
      (assert (not (string-contains? src "../../asl-contracts/src/tool_plane"))
              "tool_plane_test.asl must not contain unresolved relative imports")
      (assert (string-contains? src "asl-contracts/tool-plane")
              "tool_plane_test.asl must import canonical asl-contracts/tool-plane")
      (assert (string-contains? src "asl-agent-bus/tool-plane")
              "tool_plane_test.asl must import canonical asl-agent-bus/tool-plane")
      (assert (>= assert-count 10)
              "tool_plane_test.asl must declare at least 10 assertion forms")
      (assert (string-contains? src "run-tests") "tool_plane_test.asl must export run-tests")
      true)))

(df TestBrowserBridgeSuiteRepaired [] -> Bool
  :d "Verifies that agent-bus/tests/browser-bridge-test.asl compiles cleanly with canonical imports and CORS assertions"
  (let [(res (file-read "agent-bus/tests/browser-bridge-test.asl"))]
    (assert (= (.-_tag res) "ok") "agent-bus/tests/browser-bridge-test.asl must exist and be readable")
    (let [(src (.-value res))
          (assert-count (list-length (string-split src "(assert")))]
      (assert (> (string-length src) 0) "browser-bridge-test.asl must not be empty")
      (assert (not (string-contains? src "core/strings"))
              "browser-bridge-test.asl must not import deprecated core/strings")
      (assert (string-contains? src "asl-text/string")
              "browser-bridge-test.asl must import canonical asl-text/string")
      (assert (string-contains? src "Access-Control-Allow-Origin")
              "browser-bridge-test.asl must verify genuine CORS headers rather than trivial assert true")
      (assert (>= assert-count 15)
              "browser-bridge-test.asl must declare at least 15 assertion forms")
      (assert (string-contains? src "run-tests") "browser-bridge-test.asl must export run-tests")
      true)))

(df TestMeshOrchestrationSuiteHealthy [] -> Bool
  :d "Verifies that agent-bus/tests/mesh_orchestration_test.asl carries assertions and refutations"
  (let [(res (file-read "agent-bus/tests/mesh_orchestration_test.asl"))]
    (assert (= (.-_tag res) "ok") "agent-bus/tests/mesh_orchestration_test.asl must exist and be readable")
    (let [(src (.-value res))
          (assert-count (list-length (string-split src "(assert")))]
      (assert (> (string-length src) 0) "mesh_orchestration_test.asl must not be empty")
      (assert (string-contains? src "run-tests") "mesh_orchestration_test.asl must define run-tests")
      (assert (>= assert-count 5) "mesh_orchestration_test.asl must contain assertions")
      (assert (string-contains? src "refute") "mesh_orchestration_test.asl must exercise dual-polarity refutations")
      true)))

(df TestGatewaySuiteHealthy [] -> Bool
  :d "Verifies that agent-bus/tests/gateway-test.asl carries rich assertions, and telemetry records execution"
  (let [(res (file-read "agent-bus/tests/gateway-test.asl"))
        (telem-res (file-read ".asl/mem/telemetry/TestExecution20260912.asn"))]
    (assert (= (.-_tag res) "ok") "agent-bus/tests/gateway-test.asl must exist and be readable")
    (assert (= (.-_tag telem-res) "ok") ".asl/mem/telemetry/TestExecution20260912.asn must exist and be readable")
    (let [(src (.-value res))
          (telem-src (.-value telem-res))
          (assert-count (list-length (string-split src "(assert")))]
      (assert (> (string-length src) 0) "gateway-test.asl must not be empty")
      (assert (string-contains? src "run-tests") "gateway-test.asl must define run-tests")
      (assert (>= assert-count 25) "gateway-test.asl must declare comprehensive assertions")
      (assert (string-contains? telem-src "agent-bus") "telemetry must record agent-bus execution metrics")
      true)))

(df RunTests [] -> Bool
  (and (TestToolPlaneSuiteRepaired)
       (TestBrowserBridgeSuiteRepaired)
       (TestMeshOrchestrationSuiteHealthy)
       (TestGatewaySuiteHealthy)))
