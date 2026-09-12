(module tests/acceptance/d81/Task43701
  :d "Acceptance fixture for Task43701: settle CLI integration boundary and retire unused MCP projections under ADR-0081."
  :x [run-tests
      test-mcp-bridge-files-removed
      test-mcp-manifest-deregistered
      test-mcp-grammar-cleaned
      test-cli-integration-healthy]
  :i [])

(df test-mcp-bridge-files-removed [] -> Bool
  :d "Verifies that unused MCP bridge files are completely removed from harness"
  (let [(f1 (file-read "harness/src/mcp_bridge.asl"))
        (f2 (file-read "harness/tests/mcp_bridge_test.asl"))]
    (assert (= (.-_tag f1) "err") "harness/src/mcp_bridge.asl must be removed")
    (assert (= (.-_tag f2) "err") "harness/tests/mcp_bridge_test.asl must be removed")
    true))

(df test-mcp-manifest-deregistered [] -> Bool
  :d "Verifies that harness/manifest.asn no longer lists mcp-bridge module or export"
  (let [(res (file-read "harness/manifest.asn"))]
    (assert (= (.-_tag res) "ok") "harness/manifest.asn must exist")
    (let [(src (.-value res))]
      (assert (not (string-contains? src "mcp-bridge")) "harness/manifest.asn must not contain mcp-bridge")
      (assert (not (string-contains? src "mcp_bridge")) "harness/manifest.asn must not contain mcp_bridge")
      true)))

(df test-mcp-grammar-cleaned [] -> Bool
  :d "Verifies that harness/grammar.asn has retired McpServerConfig and mcp export"
  (let [(res (file-read "harness/grammar.asn"))]
    (assert (= (.-_tag res) "ok") "harness/grammar.asn must exist")
    (let [(src (.-value res))]
      (assert (not (string-contains? src "McpServerConfig")) "harness/grammar.asn must not contain McpServerConfig")
      (assert (not (string-contains? src "generate-claude-mcp-config")) "harness/grammar.asn must not contain generate-claude-mcp-config")
      true)))

(df test-cli-integration-healthy [] -> Bool
  :d "Verifies that CLI integration boundary remains intact and healthy"
  (let [(res (file-read "asl/grammar/rules.asn"))]
    (assert (= (.-_tag res) "ok") "asl/grammar/rules.asn must exist and be readable")
    (let [(src (.-value res))]
      (assert (string-contains? src ":rule :id foreign") "canonical rules must retain foreign boundary rule")
      (assert (string-contains? src "no MCP") "foreign rule must explicitly enforce no MCP")
      true)))

(df run-tests [] -> Bool
  :d "Executes all Task43701 supervisor acceptance tests"
  (do
    (assert (test-mcp-bridge-files-removed) "test-mcp-bridge-files-removed must pass")
    (assert (test-mcp-manifest-deregistered) "test-mcp-manifest-deregistered must pass")
    (assert (test-mcp-grammar-cleaned) "test-mcp-grammar-cleaned must pass")
    (assert (test-cli-integration-healthy) "test-cli-integration-healthy must pass")
    true))
