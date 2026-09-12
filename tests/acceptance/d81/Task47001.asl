(module tests/acceptance/d81/Task47001
  :d "Acceptance fixture for Task47001: Gate 5 audits the corpus, not a directory under ADR-0081."
  :x [RunTests
      TestGate5CorpusScopeInAslC
      TestGate5ScopeReporting
      TestGate5RunnerWorkspaceTarget]
  :i [])

(df TestGate5CorpusScopeInAslC [] -> Bool
  :d "Verifies that run_gate_5_suites in asl.c audits the workspace corpus and declares its scope"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "run_gate_5_suites")
              "asl.c must implement run_gate_5_suites")
      (assert (not (string-contains? c-src "collect_tree_files(ws_root, \"asl/packages/asl-gates/tests\""))
              "asl.c must not restrict collect_tree_files in gate 5 to asl-gates/tests")
      (assert (not (string-contains? c-src "runner_script, \"asl/packages/asl-gates/tests\""))
              "asl.c must not hardcode runner target to asl-gates/tests")
      true)))

(df TestGate5ScopeReporting [] -> Bool
  :d "Verifies that Gate 5 reports its audited scope in the output so it cannot narrow silently"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (string-contains? c-src "[scope:")
              "Gate 5 output must declare its scope explicitly")
      true)))

(df TestGate5RunnerWorkspaceTarget [] -> Bool
  :d "Verifies that run_gate_5_suites targets the workspace root or declared scope"
  (let [(c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag c-res) "ok") "asl/tools/asl.c must exist")
    (let [(c-src (.-value c-res))]
      (assert (or (string-contains? c-src "runner_target") (string-contains? c-src "target_scope") (string-contains? c-src "ws_root"))
              "asl.c must dynamically set runner target")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task47001 supervisor acceptance tests"
  (do
    (assert (TestGate5CorpusScopeInAslC) "TestGate5CorpusScopeInAslC must pass")
    (assert (TestGate5ScopeReporting) "TestGate5ScopeReporting must pass")
    (assert (TestGate5RunnerWorkspaceTarget) "TestGate5RunnerWorkspaceTarget must pass")
    true))
