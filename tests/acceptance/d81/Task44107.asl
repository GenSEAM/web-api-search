(module tests/acceptance/d81/Task44107
  :d "Acceptance fixture for Task44107: Document the verified portable loop and current fallbacks under ADR-0081."
  :x [RunTests
      TestDocumentedPortableLoopStructure
      TestCapabilitiesFallbackSpecifications
      TestRulesSurfaceIntegrity
      TestWhereOperationSituationSlice]
  :i [])

(df TestDocumentedPortableLoopStructure [] -> Bool
  :d "Verifies that asl-toolbelt/SKILL.md documents the verified loop and explicit fallbacks"
  (let [(s-res (file-read ".agents/skills/asl-toolbelt/SKILL.md"))]
    (assert (= (.-_tag s-res) "ok") ".agents/skills/asl-toolbelt/SKILL.md must exist and be readable")
    (let [(src (.-value s-res))]
      (assert (string-contains? src "Verified Portable Loop & Current Fallbacks") "Must declare Verified Portable Loop section")
      (assert (string-contains? src "Plan & Orient") "Must document Plan & Orient step")
      (assert (string-contains? src "Bounded Reading") "Must document Bounded Reading step")
      (assert (string-contains? src "Atomic Modification & Gate Verification") "Must document Atomic Modification step")
      (assert (string-contains? src "Session Continuity & Handoff") "Must document Session Continuity step")
      (assert (string-contains? src "Fallback") "Must document explicit fallbacks")
      (assert (string-contains? src "(:where)") "Must document where op")
      (assert (string-contains? src "(:budget)") "Must document budget op")
      (assert (string-contains? src "(:handoff)") "Must document handoff op")
      (assert (string-contains? src "(:resume)") "Must document resume op")
      true)))

(df TestCapabilitiesFallbackSpecifications [] -> Bool
  :d "Verifies that capabilities.asn specifies explicit fallbacks for all situation capabilities"
  (let [(c-res (file-read "asl/grammar/capabilities.asn"))]
    (assert (= (.-_tag c-res) "ok") "capabilities.asn must exist and be readable")
    (let [(src (.-value c-res))]
      (assert (string-contains? src ":situation :id orient") "Must declare orient situation")
      (assert (string-contains? src ":situation :id find") "Must declare find situation")
      (assert (string-contains? src ":situation :id read") "Must declare read situation")
      (assert (string-contains? src ":situation :id understand") "Must declare understand situation")
      (assert (string-contains? src ":situation :id plan") "Must declare plan situation")
      (assert (string-contains? src ":situation :id change") "Must declare change situation")
      (assert (string-contains? src ":situation :id verify") "Must declare verify situation")
      (assert (string-contains? src ":situation :id recover") "Must declare recover situation")
      (assert (string-contains? src ":situation :id handoff") "Must declare handoff situation")
      (assert (string-contains? src ":situation :id observe") "Must declare observe situation")
      (assert (string-contains? src ":fallback") "Must define fallback field across capabilities")
      true)))

(df TestRulesSurfaceIntegrity [] -> Bool
  :d "Verifies that install.sh maintains rule synchronization across surfaces"
  (let [(i-res (file-read "scripts/install.sh"))]
    (assert (= (.-_tag i-res) "ok") "scripts/install.sh must exist and be readable")
    (let [(src (.-value i-res))]
      (assert (string-contains? src "--check-rules") "install.sh must implement --check-rules")
      (assert (string-contains? src "--render-rules") "install.sh must implement --render-rules")
      (assert (string-contains? src "extract_between") "install.sh must implement extract_between")
      (assert (string-contains? src "render_between") "install.sh must implement render_between")
      true)))

(df TestWhereOperationSituationSlice [] -> Bool
  :d "Verifies that asl.c implements op_where and returns situation capability slices"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist and be readable")
    (let [(src (.-value c-res))]
      (assert (string-contains? src "op_where") "Must implement op_where in asl.c")
      (assert (string-contains? src ":capabilities-slice") "Must output :capabilities-slice")
      (assert (string-contains? src "strcmp(step_kind, \"change\") == 0") "Must slice for change kind")
      (assert (string-contains? src "strcmp(step_kind, \"verify\") == 0") "Must slice for verify kind")
      (assert (string-contains? src "strcmp(step_kind, \"orient\") == 0") "Must slice for orient kind")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44107 supervisor acceptance tests"
  (do
    (assert (TestDocumentedPortableLoopStructure) "TestDocumentedPortableLoopStructure must pass")
    (assert (TestCapabilitiesFallbackSpecifications) "TestCapabilitiesFallbackSpecifications must pass")
    (assert (TestRulesSurfaceIntegrity) "TestRulesSurfaceIntegrity must pass")
    (assert (TestWhereOperationSituationSlice) "TestWhereOperationSituationSlice must pass")
    true))
