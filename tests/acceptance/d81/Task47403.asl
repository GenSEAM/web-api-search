(module tests/acceptance/d81/Task47403
  :d "Acceptance fixture for Task47403: launcher specific declarations and named client invariants."
  :x [RunTests
      TestClientLauncherProtocolContract
      TestLauncherClientInvariantsImplemented
      TestLauncherChannelValidation]
  :i [])

(df TestClientLauncherProtocolContract [] -> Bool
  :d "Verifies that protocol-conformance.asn declares client launcher contracts and invariants"
  (let [(res (file-read "asl/grammar/protocol-conformance.asn"))]
    (assert (= (.-_tag res) "ok") "protocol-conformance.asn must exist")
    (let [(src (.-value res))]
      (assert (string-contains? src ":contract :id clientLauncher")
              "protocol-conformance.asn must declare clientLauncher contract")
      (assert (string-contains? src ":id \"claude\"")
              "protocol-conformance.asn must declare claude client")
      (assert (string-contains? src ":id \"agy\"")
              "protocol-conformance.asn must declare agy client")
      (assert (string-contains? src "claudeSystemPromptAppend")
              "protocol-conformance.asn must declare claudeSystemPromptAppend invariant")
      (assert (string-contains? src "claudeStripDangerousPermissions")
              "protocol-conformance.asn must declare claudeStripDangerousPermissions invariant")
      true)))

(df TestLauncherClientInvariantsImplemented [] -> Bool
  :d "Verifies that asl.c implements named invariant enforcement functions"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "enforce_claude_system_prompt_append")
              "asl.c must implement enforce_claude_system_prompt_append")
      (assert (string-contains? c-src "enforce_claude_strip_dangerous_permissions")
              "asl.c must implement enforce_claude_strip_dangerous_permissions")
      (assert (string-contains? c-src "lookup_client_spec")
              "asl.c must implement lookup_client_spec")
      true)))

(df TestLauncherChannelValidation [] -> Bool
  :d "Verifies that asl.c validates client channel and rejects undeclared clients"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "g_client_specs")
              "asl.c must define g_client_specs table")
      (assert (string-contains? c-src "Unknown or undeclared client")
              "asl.c must reject unknown or undeclared client")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47403 supervisor acceptance tests"
  (do
    (assert (TestClientLauncherProtocolContract) "TestClientLauncherProtocolContract must pass")
    (assert (TestLauncherClientInvariantsImplemented) "TestLauncherClientInvariantsImplemented must pass")
    (assert (TestLauncherChannelValidation) "TestLauncherChannelValidation must pass")
    true))
