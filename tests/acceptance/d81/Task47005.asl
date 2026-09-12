(module tests/acceptance/d81/Task47005
  :d "Acceptance fixture for Task47005: A gate cannot narrow its own scope without saying so under ADR-0081."
  :x [RunTests
      TestGateScopeDeclaredInOutput
      TestCoverageRecomputedOnEachRun
      TestDeclaredReductionAppearsInOutput]
  :i [])

(df TestGateScopeDeclaredInOutput [] -> Bool
  :d "Verifies that gate 5 reports its scope explicitly in the output so narrowing is never silent"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "run_gate_5_suites") "asl.c must define run_gate_5_suites")
      (assert (string-contains? c-src "[scope: %s]") "gate 5 must declare its audited scope in output")
      true)))

(df TestCoverageRecomputedOnEachRun [] -> Bool
  :d "Verifies that gate extent is dynamically collected from the tree on each run rather than hardcoded"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "collect_tree_files(ws_root, target_scope")
              "gate 5 must collect tree files matching target scope dynamically")
      (assert (string-contains? c-src "collect_tree_files(ws_root, \"\", \".asn\", \"grammar.asn\"")
              "gate 6 must discover grammar files dynamically")
      (assert (string-contains? c-src "collect_tree_files(root_dir, \"\", \".md\", \"SKILL.md\"")
              "gate 7 must discover skill files dynamically")
      true)))

(df TestDeclaredReductionAppearsInOutput [] -> Bool
  :d "Verifies that declared scope reductions via ASL_GATE_SCOPE are honored and announced"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "getenv(\"ASL_GATE_SCOPE\")")
              "asl.c must read ASL_GATE_SCOPE environment override")
      (assert (string-contains? c-src "runner_cmd")
              "asl.c must assemble runner command with scope")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47005 supervisor acceptance tests"
  (do
    (assert (TestGateScopeDeclaredInOutput) "TestGateScopeDeclaredInOutput must pass")
    (assert (TestCoverageRecomputedOnEachRun) "TestCoverageRecomputedOnEachRun must pass")
    (assert (TestDeclaredReductionAppearsInOutput) "TestDeclaredReductionAppearsInOutput must pass")
    true))
