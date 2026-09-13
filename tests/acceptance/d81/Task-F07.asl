(module tests/acceptance/d81/Task-F07
  :d "Acceptance fixture for Task-F07: Replace Hardcoded Magic Numbers in Tools Gate Suite under ADR-0081."
  :x [RunTests
      TestToolsGateSourceEliminatesMagicNumbers
      TestCollectWorkspaceMetricsExported
      TestLiveMetricsValues
      TestRunGateSuiteEvaluatesCleanly
      TestTaskF07GroundedInPhaseFINSEL]
  :i [("../../../tools/gate" :a tg)])

(df TestToolsGateSourceEliminatesMagicNumbers [] -> Bool
  :d "Verifies tools/gate.asl source does not execute hardcoded magic numbers"
  (let [(g-res (file-read "tools/gate.asl"))]
    (assert (= (.-_tag g-res) "ok") "tools/gate.asl must exist and be readable")
    (let [(g-src (.-value g-res))]
      (assert (not (string-contains? g-src "(run-all-seven-gates 35 793 12 0 272 3737 22)"))
              "tools/gate.asl must not execute hardcoded magic numbers 35 793 12 0 272 3737 22")
      (assert (string-contains? g-src "collect-workspace-gate-metrics")
              "tools/gate.asl must define collect-workspace-gate-metrics")
      true)))

(df TestCollectWorkspaceMetricsExported [] -> Bool
  :d "Verifies that tools/gate.asl exports collect-workspace-gate-metrics"
  (let [(g-res (file-read "tools/gate.asl"))]
    (assert (= (.-_tag g-res) "ok") "tools/gate.asl must exist and be readable")
    (let [(g-src (.-value g-res))]
      (assert (string-contains? g-src ":x [") "tools/gate.asl must have exports list")
      (assert (string-contains? g-src "collect-workspace-gate-metrics")
              "collect-workspace-gate-metrics must be declared in tools/gate.asl")
      (assert (string-contains? g-src "WorkspaceGateMetrics")
              "WorkspaceGateMetrics must be declared in tools/gate.asl")
      true)))

(df ! TestLiveMetricsValues [] -> Bool
  :d "Verifies that collect-workspace-gate-metrics discovers authentic metrics from disk"
  (let [(m (tg/collect-workspace-gate-metrics))]
    (assert (> (.-manifests m) 0) "Discovered manifests must be > 0")
    (assert (> (.-asl-files m) 0) "Discovered ASL files must be > 0")
    (assert (>= (.-claims m) 12) "Discovered benchmark claims must be >= 12")
    (assert (= (.-foreign-files m) 0) "Foreign files count must equal 0")
    (assert (> (.-test-suites m) 0) "Discovered test suites must be > 0")
    (assert (> (.-grammar-symbols m) 1000) "Discovered grammar symbols must be > 1000")
    (assert (> (.-skills m) 0) "Discovered modular skills must be > 0")
    true))

(df ! TestRunGateSuiteEvaluatesCleanly [] -> Bool
  :d "Verifies that run-gate-suite executes live verification and passes all 7 gates"
  (let [(cfg (tg/make-gate-config "." 2 false true))
        (rep (tg/run-gate-suite cfg))
        (s (.-summary rep))]
    (assert (= (.-total-gates s) 7) "Total gates must equal 7")
    (assert (= (.-passed-gates s) 7) "All 7 gates must pass under live metrics")
    (assert (.-all-clean s) "Gate summary all-clean must be true")
    true))

(df TestTaskF07GroundedInPhaseFINSEL [] -> Bool
  :d "Verifies that Task-F07 is registered in PhaseFINSELRemediation.asn"
  (let [(f-res (file-read ".asl/mem/tasks/PhaseFINSELRemediation.asn"))]
    (assert (= (.-_tag f-res) "ok") "PhaseFINSELRemediation.asn must exist and be readable")
    (let [(f-src (.-value f-res))]
      (assert (string-contains? f-src ":id \"Task-F07\"") "Must declare Task-F07")
      (assert (string-contains? f-src "tools/gate.asl") "Must own tools/gate.asl")
      true)))

(df ! RunTests [] -> Bool
  :d "Runs all Task-F07 acceptance checks"
  (do
    (assert (TestToolsGateSourceEliminatesMagicNumbers) "TestToolsGateSourceEliminatesMagicNumbers must pass")
    (assert (TestCollectWorkspaceMetricsExported) "TestCollectWorkspaceMetricsExported must pass")
    (assert (TestLiveMetricsValues) "TestLiveMetricsValues must pass")
    (assert (TestRunGateSuiteEvaluatesCleanly) "TestRunGateSuiteEvaluatesCleanly must pass")
    (assert (TestTaskF07GroundedInPhaseFINSEL) "TestTaskF07GroundedInPhaseFINSEL must pass")
    true))
