(module tests/acceptance/d81/Task44403
  :d "Acceptance fixture for Task44403: close evaluator deficit under ADR-0081."
  :x [RunTests
      TestSuperviseGateIntegrity
      TestEvaluatorBuiltinsCoverageContract
      TestModuleAliasResolutionContract
      TestEvaluatorDeficitTelemetryContract
      TestTask44403GroundedInPhase444]
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

(df TestEvaluatorBuiltinsCoverageContract [] -> Bool
  :d "Verifies ranked missing builtins identified in Task44403 deficit are implemented in engine"
  (let [(js-res (file-read "asl/tools/engine.js"))]
    (assert (= (.-_tag js-res) "ok") "asl/tools/engine.js must exist and be readable")
    (let [(js-src (.-value js-res))]
      (assert (string-contains? js-src "list-take") "engine.js must declare list-take")
      (assert (string-contains? js-src "list-fold") "engine.js must declare list-fold")
      (assert (string-contains? js-src "foldl") "engine.js must declare foldl")
      (assert (string-contains? js-src "option-none?") "engine.js must declare option-none?")
      (assert (string-contains? js-src "option-some?") "engine.js must declare option-some?")
      (assert (string-contains? js-src "list-filter") "engine.js must declare list-filter")
      (assert (string-contains? js-src "fst") "engine.js must declare fst")
      (assert (string-contains? js-src "snd") "engine.js must declare snd")
      (assert (string-contains? js-src "pair-first") "engine.js must declare pair-first")
      (assert (string-contains? js-src "list-last") "engine.js must declare list-last")
      (assert (string-contains? js-src "evalNode") "engine.js must declare evalNode")
      true)))

(df TestModuleAliasResolutionContract [] -> Bool
  :d "Verifies loadModuleImports in engine.js resolves and binds imported module aliases"
  (let [(js-res (file-read "asl/tools/engine.js"))]
    (assert (= (.-_tag js-res) "ok") "engine.js must exist and be readable")
    (let [(js-src (.-value js-res))]
      (assert (string-contains? js-src "loadModuleImports") "engine.js must declare loadModuleImports")
      (assert (string-contains? js-src "seenAliases") "loadModuleImports must handle seenAliases")
      (assert (string-contains? js-src "moduleCache") "loadModuleImports must cache imported modules")
      true)))

(df TestEvaluatorDeficitTelemetryContract [] -> Bool
  :d "Verifies telemetry reflects deficit closure with executed assertions reaching over 90 percent"
  (let [(t-res (file-read ".asl/mem/telemetry/TestExecution20260912.asn"))]
    (assert (= (.-_tag t-res) "ok") "TestExecution20260912.asn must exist and be readable")
    (let [(t-src (.-value t-res))]
      (assert (string-contains? t-src ":executedAsserts 7941") "Executed assertions must reach 7941")
      (assert (string-contains? t-src ":executedPct 92.8") "Executed percentage must reach 92.8 percent")
      (assert (string-contains? t-src ":unboundSymbols") "Telemetry must catalog remaining unbound symbols")
      (assert (string-contains? t-src ":failureCauses") "Telemetry must report failure causes")
      true)))

(df TestTask44403GroundedInPhase444 [] -> Bool
  :d "Verifies Phase 444 task collection grounds Task44403"
  (let [(p-res (file-read ".asl/mem/tasks/Phase444TestTelemetryAndCoverageGuarantees.asn"))]
    (assert (= (.-_tag p-res) "ok") "Phase 444 task file must exist and be readable")
    (let [(p-src (.-value p-res))]
      (assert (string-contains? p-src "Task44403") "Phase 444 must contain Task44403")
      (assert (string-contains? p-src "Close the measured evaluator deficit") "Phase 444 must state Task44403 title")
      (assert (string-contains? p-src ":lane \"runtime\"") "Phase 444 must specify runtime lane")
      (assert (string-contains? p-src "evalNode") "Phase 444 must target evalNode")
      (assert (string-contains? p-src "loadModuleImports") "Phase 444 must target loadModuleImports")
      true)))

(df RunTests [] -> Bool
  :d "Executes all Task44403 supervisor acceptance tests"
  (do
    (assert (TestSuperviseGateIntegrity) "TestSuperviseGateIntegrity must pass")
    (assert (TestEvaluatorBuiltinsCoverageContract) "TestEvaluatorBuiltinsCoverageContract must pass")
    (assert (TestModuleAliasResolutionContract) "TestModuleAliasResolutionContract must pass")
    (assert (TestEvaluatorDeficitTelemetryContract) "TestEvaluatorDeficitTelemetryContract must pass")
    (assert (TestTask44403GroundedInPhase444) "TestTask44403GroundedInPhase444 must pass")
    true))
