(module tests/acceptance/d81/Task44401
  :d "Acceptance fixture for Task44401: test telemetry record under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestTelemetryEngineTargetSymbolsContract
      TestTelemetryRecordArtifactsContract
      TestTelemetryBehavioralContract
      TestTask44401GroundedInPhase444]
  :i [])

(df TestSuperviseGateIntegrity [] -> Bool
  :d "Verifies SuperviseGate.sh enforces task dispatch, strict falsify, and multi-stage verification"
  (let [(s-res (file-read "tests/acceptance/d81/SuperviseGate.sh"))]
    (assert (= (.-_tag s-res) "ok") "SuperviseGate.sh must exist and be readable")
    (let [(s-src (.-value s-res))]
      (assert (string-contains? s-src "Task[0-9][0-9][0-9][0-9][0-9]") "Must validate 5-digit task id pattern")
      (assert (string-contains? s-src "audit gates") "Must invoke pure ASL verification gates")
      (assert (string-contains? s-src "audit consistency") "Must invoke consistency audit")
      true)))

(df TestTelemetryEngineTargetSymbolsContract [] -> Bool
  :d "Verifies target symbols assertionCount, evalNode, and run_gate_5 are present in engine and host"
  (let [(js-res (file-read "asl/tools/engine.js"))
        (c-res (file-read "asl/tools/asl.c"))]
    (assert (= (.-_tag js-res) "ok") "engine.js must exist and be readable")
    (assert (= (.-_tag c-res) "ok") "asl.c must exist and be readable")
    (let [(js-src (.-value js-res))
          (c-src (.-value c-res))]
      (assert (string-contains? js-src "assertionCount") "engine.js must declare assertionCount")
      (assert (string-contains? js-src "evalNode") "engine.js must implement evalNode")
      (assert (string-contains? js-src ":metrics") "engine.js must emit :metrics telemetry record")
      (assert (string-contains? c-src "run_gate_5_suites") "asl.c must implement run_gate_5_suites")
      (assert (string-contains? c-src "--metrics") "asl.c test runner must support --metrics flag")
      true)))

(df TestTelemetryRecordArtifactsContract [] -> Bool
  :d "Verifies session telemetry records per-assertion identity, timing, and unbound deficit"
  (let [(t-res (file-read ".asl/mem/telemetry/TestExecution20260912.asn"))]
    (assert (= (.-_tag t-res) "ok") "TestExecution20260912.asn must exist and be readable")
    (let [(t-src (.-value t-res))]
      (assert (string-contains? t-src ":declaredAsserts") "Telemetry must report declared assertions")
      (assert (string-contains? t-src ":executedAsserts") "Telemetry must report executed assertions")
      (assert (string-contains? t-src ":unboundSymbols") "Telemetry must record unbound symbols deficit")
      (assert (string-contains? t-src ":failureCauses") "Telemetry must classify failure causes")
      (assert (string-contains? t-src ":totalWallMs") "Telemetry must report execution duration")
      (assert (string-contains? t-src ":byPackage") "Telemetry must report breakdown by package")
      true)))

(df TestTelemetryBehavioralContract [] -> Bool
  :d "Verifies behavioral requirements: abandoned body reports executed 0 with blocking symbol named; assertion identities stable"
  (let [(t-res (file-read ".asl/mem/telemetry/TestExecution20260912.asn"))
        (js-res (file-read "asl/tools/engine.js"))]
    (assert (= (.-_tag t-res) "ok") "telemetry must exist")
    (assert (= (.-_tag js-res) "ok") "engine.js must exist")
    (let [(t-src (.-value t-res))
          (js-src (.-value js-res))]
      (assert (string-contains? t-src "ERR_UNBOUND_SYMBOL") "Telemetry must attribute abandoned suites to ERR_UNBOUND_SYMBOL")
      (assert (string-contains? js-src "ERR_UNBOUND_SYMBOL: unknown builtin or function") "Evaluator must report missing symbol diagnostic")
      (assert (string-contains? js-src "wantsMetrics") "Evaluator must support wantsMetrics telemetry mode")
      true)))

(df TestTask44401GroundedInPhase444 [] -> Bool
  :d "Verifies Phase 444 task collection grounds Task44401"
  (let [(p-res (file-read ".asl/mem/tasks/Phase444TestTelemetryAndCoverageGuarantees.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 444 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Test telemetry record") "Phase 444 must state Task44401 title")
      (assert (string-contains? p-src ":lane \"telemetry\"") "Phase 444 must specify telemetry lane")
      (assert (string-contains? p-src "assertionCount") "Phase 444 must target assertionCount")
      (assert (string-contains? p-src "evalNode") "Phase 444 must target evalNode")
      (assert (string-contains? p-src "run_gate_5") "Phase 444 must target run_gate_5")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44401 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestTelemetryEngineTargetSymbolsContract) "TestTelemetryEngineTargetSymbolsContract must pass")
    (assert (TestTelemetryRecordArtifactsContract) "TestTelemetryRecordArtifactsContract must pass")
    (assert (TestTelemetryBehavioralContract) "TestTelemetryBehavioralContract must pass")
    (assert (TestTask44401GroundedInPhase444) "TestTask44401GroundedInPhase444 must pass")
    true))
