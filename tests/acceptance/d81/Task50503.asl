(module tests/acceptance/d81/Task50503
  :d "Acceptance fixture for Task 50503: Resynchronize Package Manifests and Module Declarations per D77 and D34"
  :x [testPluginModuleResolution
      testShModulesResolution
      testManifestsSyntaxCheck
      testManifestModulesDynamicExecution
      RunTests]
  :i [(asl-plugin/dynamicTool :a dt)
      (asl-sh/gitDiff         :a gd)
      (asl-sh/batchDag        :a bd)
      (asl-text/text          :a txt)])

(df testPluginModuleResolution [] -> Bool
  :d "Verifies functional resolution of canonical asl-plugin/dynamicTool module and asl-text dependency"
  (let [(plane (dt/emptyPlane))
        (param (dt/createParam "limit" "Int64" true "Row limit"))
        (toks (txt/estimateTokens "sample query text"))]
    (assert (= (dt/toolCount plane) 4) "Empty plane must have 4 base tools")
    (refute (!= (dt/toolCount plane) 4) "Tool count must refute not 4")
    (assert (= (map-size (.-mountedTools plane)) 0) "Mounted tools map must be empty")
    (refute (!= (map-size (.-mountedTools plane)) 0) "Mounted tools map must refute non-zero")
    (assert (= (.-name param) "limit") "Param name must match")
    (refute (!= (.-name param) "limit") "Param name must refute mismatch")
    (assert (> toks 0) "asl-text estimateTokens must return positive token count")
    (refute (<= toks 0) "Token estimate must refute <= 0")
    true))

(df testShModulesResolution [] -> Bool
  :d "Verifies functional resolution of canonical asl-sh/gitDiff, asl-sh/batchDag modules, and asl-text dependency"
  (let [(step (bd/dagStepCreate 1 "lint" "run" "lint" (list)))
        (plan (bd/dagPlanCreate "seq" (list step)))
        (diffText (str "diff --git a/src/main.rs b/src/main.rs\n"
                       "--- a/src/main.rs\n"
                       "+++ b/src/main.rs\n"
                       "@@ -1,1 +1,1 @@\n"
                       "-old\n"
                       "+new\n"))
        (files (gd/gitDiffParse diffText))
        (summary (gd/gitDiffSummary files))
        (toks (txt/estimateTokens "diff --git a/test b/test"))]
    (assert (.-isValid plan) "Created DAG plan must be valid")
    (refute (not (.-isValid plan)) "Plan must refute invalid")
    (assert (= (list-length files) 1) "Parsed diff must contain 1 file")
    (refute (!= (list-length files) 1) "Parsed diff must refute not 1 file")
    (assert (string-contains? summary ":files 1") "Summary must report 1 total file")
    (refute (string-contains? summary ":files 0") "Summary must refute 0 files")
    (assert (> toks 0) "Token estimate must be positive")
    (refute (<= toks 0) "Token estimate must refute <= 0")
    true))

(df testManifestsSyntaxCheck [] -> Bool
  :d "Verifies package manifests are well-formed and pass delimiter balance checks via bin/asl check"
  (let [(res (sys-exec "bin/asl check asl/packages/asl-plugin/manifest.asn asl/packages/asl-sh/manifest.asn"))
        (code (.-exitCode res))]
    (assert (= code 0) (str "Manifest check must exit 0: " (.-stderr res)))
    (refute (!= code 0) "Manifest check must refute non-zero exit")
    true))

(df testManifestModulesDynamicExecution [] -> Bool
  :d "Dynamically executes tests of updated modules via bin/asl CLI"
  (let [(resPlugin (sys-exec "bin/asl test asl/packages/asl-plugin/tests/dynamic_tool_test.asl"))
        (resSh (sys-exec "bin/asl test asl/packages/asl-sh/tests/git_diff_test.asl asl/packages/asl-sh/tests/batch_dag_test.asl"))]
    (assert (= (.-exitCode resPlugin) 0) (str "dynamic_tool_test must pass: " (.-stderr resPlugin)))
    (refute (!= (.-exitCode resPlugin) 0) "dynamic_tool_test must exit 0")
    (assert (= (.-exitCode resSh) 0) (str "asl-sh modules test must pass: " (.-stderr resSh)))
    (refute (!= (.-exitCode resSh) 0) "asl-sh modules test must exit 0")
    true))

(df RunTests [] -> Bool
  :d "Executes all Task 50503 acceptance tests"
  (do
    (assert (testPluginModuleResolution) "testPluginModuleResolution must pass")
    (assert (testShModulesResolution) "testShModulesResolution must pass")
    (assert (testManifestsSyntaxCheck) "testManifestsSyntaxCheck must pass")
    (assert (testManifestModulesDynamicExecution) "testManifestModulesDynamicExecution must pass")
    true))
